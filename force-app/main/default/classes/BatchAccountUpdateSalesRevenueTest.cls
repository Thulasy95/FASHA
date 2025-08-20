@isTest
private class BatchAccountUpdateSalesRevenueTest {

    @testSetup
    static void setupData() {

        // Création de comptes
        List<Account> accounts = TestDataFactory.createAccounts(5);
        insert accounts;

        // Création de commandes 'Ordered' pour ces comptes
        for (Account acc : accounts) {
            TestDataFactory.createOrdersWithOrderItems(
                1,                      // 1 commande par compte
                acc.Id,
                'Ordered',              // statut
                10,                     // shipmentCost
                1,                      // 1 OrderItem
                UserInfo.getUserId()    // propriétaire
            );
        }

    }

    @isTest static void testBatchUpdateSalesRevenue() {

        Test.startTest();

        // Instanciation et exécution du batch
        BatchAccountUpdateSalesRevenue batch = new BatchAccountUpdateSalesRevenue();
        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        // Vérifie qu'au moins un compte correspond au critère de la requête du batch
        Integer expected = [ SELECT COUNT() FROM Account WHERE Id IN (
            SELECT AccountId
            FROM Order
            WHERE Status = 'Ordered'
            AND LastModifiedDate = LAST_N_DAYS:7
        )];

        System.assert(expected > 0, 'Il devrait exister au moins un compte avec une commande Ordered.');

        for (Account acc : [ SELECT Id, SalesRevenue__c FROM Account ]) {
            System.assertEquals( 100 , acc.SalesRevenue__c , 'SalesRevenue ne correspond pas.');
        }

    }
}
