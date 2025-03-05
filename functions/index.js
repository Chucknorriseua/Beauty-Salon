const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const cron = require("node-cron");

admin.initializeApp();

const db = admin.firestore();

// Функция для отправки уведомления
async function sendNotification(userId, fcmToken, appointmentDate) {
    const message = {
        notification: {
            title: "Напоминание о записи!",
            body: `У вас запись на ${appointmentDate}. Не забудьте!`
        },
        token: fcmToken
    };

    try {
        const response = await admin.messaging().send(message);
        console.log(`✅ Уведомление отправлено пользователю ${userId}:`, response);
    } catch (error) {
        console.error("❌ Ошибка отправки уведомления:", error);
    }
}

// Функция проверки записей клиентов
async function checkAppointments() {
    const today = new Date();
    today.setDate(today.getDate() + 1); // Завтрашняя дата
    const tomorrowStr = today.toISOString().split("T")[0]; // Формат YYYY-MM-DD

    try {
        const clientsSnapshot = await db.collection("Client").get();

        if (clientsSnapshot.empty) {
            console.log("⚠️ Нет клиентов в базе.");
            return;
        }

        clientsSnapshot.forEach(async (clientDoc) => {
            const userId = clientDoc.id;
            const clientData = clientDoc.data();
            const fcmToken = clientData.fcnTokenUser; // Убедись, что у клиента есть FCM-токен

            if (!fcmToken) {
                console.log(`⚠️ У клиента ${userId} нет FCM-токена`);
                return;
            }

            const recordsRef = db.collection(`Client/${userId}/MyRecords`);
            const recordsSnapshot = await recordsRef.get();

            if (recordsSnapshot.empty) {
                console.log(`ℹ️ У клиента ${userId} нет записей.`);
                return;
            }

            recordsSnapshot.forEach(async (recordDoc) => {
                const recordData = recordDoc.data();

                let creationDateStr;
                if (recordData.creationDate.toDate) {
                    creationDateStr = recordData.creationDate.toDate().toISOString().split("T")[0];
                } else {
                    creationDateStr = recordData.creationDate;
                }

                if (creationDateStr === tomorrowStr) {
                    await sendNotification(userId, fcmToken, creationDateStr);
                }
            });
        });
    } catch (error) {
        console.error("❌ Ошибка при проверке записей:", error);
    }
}

exports.scheduledFunction = functions
    .region("europe-central2") // Указать регион
    .pubsub.schedule("0 8 * * *") // Запуск каждый день в 08:00
    .timeZone("Europe/Kyiv") // Или другой нужный часовой пояс
    .onRun(async () => {
        console.log("Отправка уведомлений в 08:00 по Европе/Киеву!");
        await checkAppointments();
    });
// Запуск задачи раз в день в 09:00 по UTC
