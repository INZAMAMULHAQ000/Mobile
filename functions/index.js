const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.checkExpiringContracts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      const firestore = admin.firestore();
      const now = admin.firestore.Timestamp.now();

      // Calculate date 15 days from now
      const fifteenDaysFromNow = new Date(now.toDate().getTime() + (15 * 24 * 60 * 60 * 1000));
      const fifteenDaysFromNowTimestamp = admin.firestore.Timestamp.fromDate(fifteenDaysFromNow);

      // Query for contracts expiring within 15 days
      const expiringContractsSnapshot = await firestore.collection('contracts')
        .where('endDate', '<=', fifteenDaysFromNowTimestamp)
        .where('endDate', '>=', now)
        .where('status', '==', 'active')
        .get();

      const notifications = [];
      const notificationPromises = [];

      // Get all admin and manager users
      const adminUsersSnapshot = await firestore.collection('users')
        .where('role', 'in', ['admin', 'manager'])
        .where('isActive', '==', true)
        .get();

      for (const contractDoc of expiringContractsSnapshot.docs) {
        const contract = contractDoc.data();

        // Get guest details
        const guestDoc = await firestore.collection('guests').doc(contract.guestId).get();
        const guest = guestDoc.data();

        // Get apartment details
        const apartmentDoc = await firestore.collection('apartments').doc(contract.apartmentId).get();
        const apartment = apartmentDoc.data();

        // Get room details
        const roomDoc = await firestore.collection('rooms').doc(contract.roomId).get();
        const room = roomDoc.data();

        const daysUntilExpiry = Math.ceil((contract.endDate.toDate() - now.toDate()) / (1000 * 60 * 60 * 24));

        // Create notifications for all admin/manager users
        for (const userDoc of adminUsersSnapshot.docs) {
          const user = userDoc.data();

          const notification = {
            userId: userDoc.id,
            title: 'Contract Expiring Soon',
            message: `${guest?.name || 'Unknown Guest'}'s contract at ${apartment?.name || 'Unknown Apartment'}, Room ${room?.roomNumber || 'Unknown'} expires in ${daysUntilExpiry} days`,
            type: 'contract_expiry',
            relatedId: contractDoc.id,
            isRead: false,
            createdAt: now,
          };

          notifications.push(notification);
          notificationPromises.push(
            firestore.collection('notifications').add(notification)
          );
        }
      }

      // Create all notifications in batch
      await Promise.all(notificationPromises);

      console.log(`Created ${notifications.length} contract expiry notifications`);

      return {
        success: true,
        notificationsCreated: notifications.length,
        contractsExpiring: expiringContractsSnapshot.size,
      };

    } catch (error) {
      console.error('Error checking expiring contracts:', error);
      throw new functions.https.HttpsError('internal', 'Failed to check expiring contracts', error);
    }
  });

exports.generateMonthlyReport = functions.https.onCall(async (data, context) => {
  try {
    // Verify user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { month, year, apartmentId } = data;

    if (!month || !year) {
      throw new functions.https.HttpsError('invalid-argument', 'Month and year are required');
    }

    const firestore = admin.firestore();

    // Create start and end dates for the specified month
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);
    const startTimestamp = admin.firestore.Timestamp.fromDate(startDate);
    const endTimestamp = admin.firestore.Timestamp.fromDate(endDate);

    // Build transaction query
    let transactionQuery = firestore.collection('transactions')
      .where('date', '>=', startTimestamp)
      .where('date', '<=', endTimestamp);

    if (apartmentId) {
      transactionQuery = transactionQuery.where('apartmentId', '==', apartmentId);
    }

    const transactionsSnapshot = await transactionQuery.get();

    // Aggregate data
    let totalIncome = 0;
    let totalExpense = 0;
    const expensesByCategory = {};
    const incomeByCategory = {};
    const transactions = [];

    for (const doc of transactionsSnapshot.docs) {
      const transaction = doc.data();
      const amount = transaction.amount;
      const category = transaction.category;

      transactions.push({
        id: doc.id,
        ...transaction,
        date: transaction.date.toDate(),
        createdAt: transaction.createdAt.toDate(),
      });

      if (transaction.type === 'income') {
        totalIncome += amount;
        incomeByCategory[category] = (incomeByCategory[category] || 0) + amount;
      } else {
        totalExpense += amount;
        expensesByCategory[category] = (expensesByCategory[category] || 0) + amount;
      }
    }

    const profitLoss = totalIncome - totalExpense;

    // Get apartment data if apartmentId is provided
    let apartmentData = null;
    if (apartmentId) {
      const apartmentDoc = await firestore.collection('apartments').doc(apartmentId).get();
      if (apartmentDoc.exists) {
        apartmentData = apartmentDoc.data();
      }
    }

    const reportData = {
      period: {
        month: month,
        year: year,
        startDate: startDate,
        endDate: endDate,
      },
      apartment: apartmentData,
      summary: {
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        profitLoss: profitLoss,
        transactionCount: transactionsSnapshot.size,
      },
      expensesByCategory: expensesByCategory,
      incomeByCategory: incomeByCategory,
      transactions: transactions,
      generatedAt: new Date(),
      generatedBy: context.auth.uid,
    };

    return reportData;

  } catch (error) {
    console.error('Error generating monthly report:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate monthly report', error);
  }
});

exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  try {
    // Verify user is authenticated and has admin/manager role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { userId, title, message, type, relatedId } = data;

    if (!userId || !title || !message) {
      throw new functions.https.HttpsError('invalid-argument', 'userId, title, and message are required');
    }

    const firestore = admin.firestore();

    // Check if sender has permission
    const senderDoc = await firestore.collection('users').doc(context.auth.uid).get();
    const sender = senderDoc.data();

    if (!sender || !['admin', 'manager'].includes(sender.role)) {
      throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }

    // Get target user's FCM token
    const targetUserDoc = await firestore.collection('users').doc(userId).get();
    const targetUser = targetUserDoc.data();

    if (!targetUser) {
      throw new functions.https.HttpsError('not-found', 'Target user not found');
    }

    // Create notification document
    const notification = {
      userId: userId,
      title: title,
      message: message,
      type: type || 'general',
      relatedId: relatedId,
      isRead: false,
      createdAt: admin.firestore.Timestamp.now(),
    };

    await firestore.collection('notifications').add(notification);

    // Send push notification if user has FCM token
    if (targetUser.fcmToken) {
      const payload = {
        notification: {
          title: title,
          body: message,
        },
        data: {
          type: type || 'general',
          relatedId: relatedId || '',
        },
        token: targetUser.fcmToken,
      };

      try {
        await admin.messaging().send(payload);
        console.log('Push notification sent successfully');
      } catch (messagingError) {
        console.error('Error sending push notification:', messagingError);
        // Don't throw error for push notification failure
      }
    }

    return {
      success: true,
      notificationId: notification.id,
    };

  } catch (error) {
    console.error('Error sending push notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send push notification', error);
  }
});

exports.updateUserActivity = functions.auth.user().onCreate(async (user) => {
  try {
    const firestore = admin.firestore();

    // Create user document if it doesn't exist
    const userRef = firestore.collection('users').doc(user.uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        uid: user.uid,
        email: user.email || '',
        name: user.displayName || 'User',
        role: 'viewer', // Default role for new users
        createdAt: admin.firestore.Timestamp.now(),
        lastLoginAt: admin.firestore.Timestamp.now(),
        isActive: true,
        photoUrl: user.photoURL,
      });

      console.log('Created user document for:', user.uid);
    }

    return { success: true };

  } catch (error) {
    console.error('Error updating user activity:', error);
    // Don't throw error for user creation to avoid blocking auth
  }
});

exports.cleanupOldNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      const firestore = admin.firestore();
      const now = admin.firestore.Timestamp.now();

      // Delete notifications older than 30 days
      const thirtyDaysAgo = new Date(now.toDate().getTime() - (30 * 24 * 60 * 60 * 1000));
      const thirtyDaysAgoTimestamp = admin.firestore.Timestamp.fromDate(thirtyDaysAgo);

      const oldNotificationsSnapshot = await firestore.collection('notifications')
        .where('createdAt', '<', thirtyDaysAgoTimestamp)
        .get();

      const batch = firestore.batch();

      oldNotificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      console.log(`Deleted ${oldNotificationsSnapshot.size} old notifications`);

      return {
        success: true,
        notificationsDeleted: oldNotificationsSnapshot.size,
      };

    } catch (error) {
      console.error('Error cleaning up old notifications:', error);
      throw new functions.https.HttpsError('internal', 'Failed to cleanup old notifications', error);
    }
  });