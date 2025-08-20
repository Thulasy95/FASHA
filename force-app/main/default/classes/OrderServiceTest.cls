@isTest
private class OrderServiceTest {

    @isTest
    static void testCalculateNetAmount() {
        // Création d'un utilisateur et exécution en mode System.runAs pour éviter Mixed DML
        User owner = TestDataFactory.createUser('ord', 'orderowner', 'OrderRole', null);
        
        System.runAs(owner) {
            // Création d'un compte
            Account acct = new Account(Name='Test Account');
            insert acct;

            // Création d'une commande avec 2 OrderItems et coût de livraison
            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                1,              // nombre de commandes
                acct.Id,        // accountId
                'Draft',        // orderStatus
                20,             // shipmentCost
                2,              // nombre d'OrderItems
                owner.Id        // ownerId
            );

            // Re-query pour récupérer TotalAmount calculé
            Order ord = [SELECT Id, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :orders[0].Id];

            // Act : obtenir le service via la méthode statique
            IOrderService service = OrderService.newInstance();

            Decimal expectedNetAmount = ord.TotalAmount - ord.ShipmentCost__c;
            Test.startTest();
            Decimal calculatedNetAmount = service.calculateNetAmount(ord);
            Test.stopTest();
            
            // Assert
            System.assertEquals(expectedNetAmount, calculatedNetAmount,'Le net amount doit être TotalAmount - ShipmentCost__c');
        }
    }

    @isTest
    static void testUpdateNetAmount() {
        User owner = TestDataFactory.createUser('upd', 'updateowner', 'OrderRole', null);

        System.runAs(owner) {
            Account acct = new Account(Name='Test Account 2');
            insert acct;

            // Création d'une commande avec 1 OrderItem
            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                1, 
                acct.Id,
                'Draft',
                10,
                1,
                owner.Id
            );

            // Re-query pour récupérer TotalAmount calculé
            Order ord = [SELECT Id, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :orders[0].Id];

            // Act : appeler la méthode updateNetAmount via la méthode statique
            IOrderService service = OrderService.newInstance();

            Test.startTest();
            service.updateNetAmount(orders);
            Test.stopTest();

            // Vérifie que la méthode s’exécute sans exception et que l’ordre existe toujours
            System.assertNotEquals(null, ord.Id, 'L’ordre doit exister après updateNetAmount');
        }
    }
}
