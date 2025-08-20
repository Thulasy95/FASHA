@isTest
private class Schedule_AccountUpdateSalesRevenueTest {

    // CRON expression factice : 1er janvier 2042 à minuit
    private static final String CRON_EXP = '0 0 0 1 1 ? 2042';

    @testSetup
    static void setupData() {
        // Création de 3 comptes
        List<Account> accounts = TestDataFactory.createAccounts(3);
        insert accounts;

        // Pour chaque compte, on crée une commande "Ordered" récente
        for (Account acc : accounts) {
            TestDataFactory.createOrdersWithOrderItems(
                1,                      // 1 Order par compte
                acc.Id,                 // lié au compte
                'Ordered',              // statut "Ordered"
                50,                     // ShipmentCost
                1,                      // 1 OrderItem
                UserInfo.getUserId()    // owner
            );
        }
    }

    @isTest
    static void testScheduledBatchExecution() {
        Test.startTest();

        // Planifie le job
        String cronId = System.schedule(
            'ScheduledApexTest',
            CRON_EXP,
            new Schedule_AccountUpdateSalesRevenue()
        );

        // Vérifie que le job est bien planifié
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :cronId 
        ];
        System.assertNotEquals(null, ct, 'Le CronTrigger doit exister avant exécution');

        // Arrêt du test = exécution du schedulable + batch
        Test.stopTest();

        List<Account> updatedAccounts = [
            SELECT Id, SalesRevenue__c
            FROM Account
        ];

        Boolean atLeastOneUpdated = false;
        
        for (Account acc : updatedAccounts) {
            if (acc.SalesRevenue__c != null && acc.SalesRevenue__c > 0) {
                atLeastOneUpdated = true;
            }
        }

        System.assert(atLeastOneUpdated, 'Au moins un compte aurait dû être mis à jour par le batch.');

    }
}

