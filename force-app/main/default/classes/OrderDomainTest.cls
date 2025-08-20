@IsTest
private class OrderDomainTest {

    @TestSetup
    static void setupData() {
        // Crée un compte de test
        List<Account> accounts = TestDataFactory.createAccounts(1);
        insert accounts;
    }

    @IsTest
    static void testUpdateNetAmount() {
        // Récupération du compte créé
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Crée des commandes et order items en mémoire via TestDataFactory
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            2,           // numOrders
            acc.Id,      // accountId
            'Draft',     // orderStatus
            10,          // shipmentCost
            2,           // numOrderItems
            UserInfo.getUserId()  // ownerId
        );

        // Crée le domaine avec les commandes
        OrderDomain domain = new OrderDomain(orders);

        // Création d’un mock fflib pour IOrderService
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOrderService mockOrderService = (IOrderService) mocks.mock(IOrderService.class);

        // Configure le mock pour retourner 500 pour chaque commande
        mocks.startStubbing();
        for (Order ord : orders) {
            mocks.when(mockOrderService.calculateNetAmount(ord)).thenReturn(500);
        }
        mocks.stopStubbing();

        Application.Service.setMock(IOrderService.class, mockOrderService);

        // Appel de la méthode en mémoire
        Test.startTest();
        domain.updateNetAmount();
        Test.stopTest();

        // Vérification en mémoire (pas besoin de DML)
        for (Order ord : orders) {
            System.assertEquals(500, ord.NetAmount__c, 'NetAmount__c doit être mis à jour avec la valeur mockée');
        }
    }

    @IsTest
    static void testUpdateNetAmountWithEmptyList() {
        // Test de la branche null / empty
        OrderDomain domain = new OrderDomain(new List<Order>());

        Test.startTest();
        domain.updateNetAmount(); // ne doit rien faire et ne pas lever d'erreur
        Test.stopTest();

        // Assertions
        List<Order> result = domain.getOrders();
        System.assertNotEquals(null, result, 'La liste retournée ne doit pas être null');
        System.assertEquals(0, result.size(), 'La liste doit rester vide après updateNetAmount()');
    }


    @IsTest
    static void testNewInstanceMethods() {
        // Crée des commandes en mémoire
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            1, acc.Id, 'Draft', 5, 1, UserInfo.getUserId()
        );

        // Test de newInstance(List<Order>)
        IOrderDomain domainList = OrderDomain.newInstance(orders);
        System.assertNotEquals(null, domainList, 'newInstance(List) doit retourner une instance');
        System.assertEquals(orders.size(), domainList.getOrders().size(),'La taille des deux listes ne correspond pas');
    }
}
