@IsTest
private class OrderTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        // Crée un compte pour les commandes
        List<Account> accounts = TestDataFactory.createAccounts(1);
        insert accounts;

    }

    @IsTest
    static void testOnApplyDefaults() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order ord = new Order(AccountId = acc.Id, EffectiveDate = Date.today(), Status = null, Pricebook2Id = Test.getStandardPricebookId());
        
        List<Order> orders = new List<Order>{ord};
        OrderTriggerHandler handler = new OrderTriggerHandler(orders);
        
        Test.startTest();
        handler.onApplyDefaults();
        Test.stopTest();
        
        System.assertEquals('Draft', ord.Status, 'Le statut par défaut doit être Draft');
    }

    @IsTest
    static void testOnValidateWithoutAccount() {
        Order ord = new Order(Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = Test.getStandardPricebookId());
        
        List<Order> orders = new List<Order>{ord};
        OrderTriggerHandler handler = new OrderTriggerHandler(orders);
        
        Test.startTest();
        try {
            handler.onValidate(); // ou update cf. testOnValidateStatusActivated
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Un compte est requis pour une commande.'), 'Le message d’erreur attendu n’a pas été trouvé.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testOnValidateStatusActivated() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Crée une commande Activated
        List<Order> existingOrders = TestDataFactory.createOrdersWithOrderItems(
            1,                      // 1 commande
            acc.Id,                 // accountId
            'Activated',            // Status
            10,                     // ShipmentCost__c
            1,                      // 1 OrderItem par commande
            UserInfo.getUserId()    // Propriétaire = utilisateur courant
        );

        Order existingOrder = existingOrders[0];

        // Tentative de modification du statut
        existingOrder.Status = 'Draft';

        Test.startTest();
        try {
            update existingOrder;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Vous ne pouvez pas modifier une commande activée.'), 'Le message d’erreur attendu n’a pas été trouvé.');
        }
        Test.stopTest();
    }

    @isTest
    static void testBeforeInsertAndAfterInsert() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,                      // nombre de commandes
            acc.Id,                 // accountId
            'Ordered',              // status
            10,                      // shipmentCost
            1,                      // nombre d'OrderItems
            UserInfo.getUserId()    // propriétaire
        );
        Test.stopTest();

        Order updatedOrd = [SELECT Id, NetAmount__c , TotalAmount, ShipmentCost__c FROM Order WHERE Id = :orders[0].Id];
        Account updatedAcc = [SELECT Id, SalesRevenue__c FROM Account WHERE Id = :acc.Id];

        Decimal calculatedNetAmount = updatedOrd.TotalAmount - updatedOrd.ShipmentCost__c;

        System.assertEquals( 90 , calculatedNetAmount,'Le net amount doit être TotalAmount - ShipmentCost__c');
        System.assertEquals( 100 , updatedAcc.SalesRevenue__c , 'SalesRevenue ne correspond pas.');

    }

    @isTest
    static void testBeforeUpdateAndAfterUpdate() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,                      // nombre de commandes
            acc.Id,                 // accountId
            'Draft',              // status
            10,                      // shipmentCost
            1,                      // nombre d'OrderItems
            UserInfo.getUserId()    // propriétaire
        );

        for (Order ord : orders) {
            ord.ShipmentCost__c = 20;
            ord.Status = 'Ordered';
        }
        
        Test.startTest();
        update orders;
        Test.stopTest();

        Order updatedOrd = [SELECT Id, NetAmount__c , TotalAmount, ShipmentCost__c FROM Order WHERE Id = :orders[0].Id];
        Account updatedAcc = [SELECT Id, SalesRevenue__c FROM Account WHERE Id = :acc.Id];

        Decimal calculatedNetAmount = updatedOrd.TotalAmount - updatedOrd.ShipmentCost__c;

        System.assertEquals( 80 , calculatedNetAmount,'Le net amount doit être TotalAmount - ShipmentCost__c');
        System.assertEquals( 100 , updatedAcc.SalesRevenue__c , 'SalesRevenue ne correspond pas.');

    }

    @isTest
    static void testAfterDelete() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1,                      // nombre de commandes
            acc.Id,                 // accountId
            'Draft',              // status
            10,                      // shipmentCost
            1,                      // nombre d'OrderItems
            UserInfo.getUserId()    // propriétaire
        );
      
        // Suppression de la commande pour déclencher afterDelete
        Test.startTest();
        delete orders;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, SalesRevenue__c FROM Account WHERE Id = :acc.Id];
        Integer countOrders = [SELECT COUNT() FROM Order WHERE Id IN :orders];

        System.assertEquals( null , updatedAcc.SalesRevenue__c , 'SalesRevenue ne correspond pas.');
        System.assertEquals( 0 , countOrders, 'La commande doit être supprimée.');
    }

    @isTest
    static void testBulkOrders() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            100,                   // nombre de commandes
            acc.Id,                 // accountId
            'Draft',                // status
            10,                     // shipmentCost
            1,                      // nombre d'OrderItems
            UserInfo.getUserId()    // propriétaire
        );

        for (Order ord : orders) {
            ord.ShipmentCost__c = 20;
            ord.Status = 'Ordered';
        }
        
        Test.startTest();
        update orders;
        Test.stopTest();

        List<Order> updatedOrd = [SELECT Id, NetAmount__c , TotalAmount, ShipmentCost__c FROM Order WHERE AccountId = :acc.Id];
        Account updatedAcc = [SELECT Id, SalesRevenue__c FROM Account WHERE Id = :acc.Id];

        for (Order o : updatedOrd) {
            Decimal calculatedNetAmount = o.TotalAmount - o.ShipmentCost__c;
            System.assertEquals( 80 , calculatedNetAmount,'Le net amount doit être TotalAmount - ShipmentCost__c');            
        }
      
        System.assertEquals( 10000 , updatedAcc.SalesRevenue__c , 'SalesRevenue ne correspond pas.');

    }

    
}
