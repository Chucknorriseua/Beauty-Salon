const admin = require("firebase-admin");
const cron = require("node-cron");

// Подключаем сервисный аккаунт
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://beautysalon-7fba7.firebaseio.com" // Указываем правильный URL
});

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
        // 1️⃣ Получаем всех клиентов
        const clientsSnapshot = await db.collection("Client").get();

        if (clientsSnapshot.empty) {
            console.log("⚠️ Нет клиентов в базе.");
            return;
        }

        // 2️⃣ Для каждого клиента проверяем его "MyRecords"
        clientsSnapshot.forEach(async (clientDoc) => {
            const userId = clientDoc.id;
            const clientData = clientDoc.data();
            const fcmToken = clientData.fcnTokenUser; // Убедись, что у клиента есть FCM-токен

            if (!fcmToken) {
                console.log(`⚠️ У клиента ${userId} нет FCM-токена`);
                return;
            }

            // 3️⃣ Проверяем записи на завтра
            const recordsRef = db.collection(`Client/${userId}/MyRecords`);
            const recordsSnapshot = await recordsRef.get();

            if (recordsSnapshot.empty) {
                console.log(`ℹ️ У клиента ${userId} нет записей.`);
                return;
            }

            // 4️⃣ Фильтруем записи по creationDate
            recordsSnapshot.forEach(async (recordDoc) => {
                const recordData = recordDoc.data();

                let creationDateStr;
                if (recordData.creationDate.toDate) {
                    // Если creationDate — это Timestamp
                    creationDateStr = recordData.creationDate.toDate().toISOString().split("T")[0];
                } else {
                    // Если creationDate уже строка (YYYY-MM-DD)
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

// Запуск проверки каждый день в 09:00
cron.schedule("0 9 * * *", () => {
    console.log("🔄 Проверяем записи на завтра...");
    checkAppointments();
});

console.log("🚀 Сервер запущен! Ожидаем проверку...");
checkAppointments(); // Запускаем сразу для теста