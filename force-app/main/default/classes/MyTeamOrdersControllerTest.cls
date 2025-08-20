@IsTest
public class MyTeamOrdersControllerTest {

@testSetup
    static void setupData() {

        // Crée un compte
        Account acc = new Account(Name='Test Account');
        insert acc;

    }

    @IsTest
    static void testControllerWithOrders() {

        // Crée un compte
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        // Crée une "liste d'ordres" fictive via TestDataFactory
        List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
            2,           // 2 commandes
            acc.Id,
            'Ordered',   // Status
            10,          // ShipmentCost__c
            1,           // 1 OrderItem par commande
            UserInfo.getUserId()  // Propriétaire = utilisateur courant
        );

        // IDs "utilisateurs de l'équipe" = juste l'utilisateur courant
        Set<Id> fakeUserIds = new Set<Id>{ UserInfo.getUserId() };

        // Création des mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUserService mockUserService = (IUserService) mocks.mock(IUserService.class);
        IOrderSelector mockOrderSelector = (IOrderSelector) mocks.mock(IOrderSelector.class);

        // Configuration des mocks
        mocks.startStubbing();
        mocks.when(mockUserService.getMyTeamUsersId()).thenReturn(fakeUserIds);
        mocks.when(mockOrderSelector.selectOrdersByStatusAndUsersId('Ordered', fakeUserIds)).thenReturn(orders);
        mocks.stopStubbing();

        // Enregistre les mocks
        Application.Service.setMock(IUserService.class, mockUserService);
        Application.Selector.setMock(mockOrderSelector);

        Test.startTest();
        MyTeamOrdersController controller = new MyTeamOrdersController();
        Test.stopTest();

        System.assertEquals(200, controller.sumOrders, 'La somme des commandes devrait être de 200');
        System.assert(controller.teamOrders.size() > 0, 'Les commandes de l’équipe doivent être récupérées');

    }

    @IsTest
    static void testControllerWithoutOrders() {

        // Création des mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUserService mockUserService = (IUserService) mocks.mock(IUserService.class);
        IOrderSelector mockOrderSelector = (IOrderSelector) mocks.mock(IOrderSelector.class);

        List<Order> emptyOrders = new List<Order>();

        // IDs "utilisateurs de l'équipe" = juste l'utilisateur courant
        Set<Id> fakeUserIds2 = new Set<Id>{ UserInfo.getUserId() };

        // Configuration des mocks
        mocks.startStubbing();
        mocks.when(mockOrderSelector.selectOrdersByStatusAndUsersId('Ordered', fakeUserIds2)).thenReturn(emptyOrders);
        mocks.stopStubbing();

        Test.startTest();
        MyTeamOrdersController controller = new MyTeamOrdersController();
        Test.stopTest();

        System.assertEquals(0, controller.sumOrders, 'Pas de commandes donc somme = 0');
        System.assertEquals(0, controller.teamOrders.size(), 'Pas de commandes récupérées');

    }

    @IsTest
    static void testControllerException() {

        Account acc3 = [SELECT Id FROM Account WHERE Name='Test Account'];

        // Crée une "liste d'ordres" fictive via TestDataFactory
        List<Order> orders3 = TestDataFactory.createOrdersWithOrderItems(
            2,           // 2 commandes
            acc3.Id,
            'Ordered',   // Status
            10,          // ShipmentCost__c
            1,           // 1 OrderItem par commande
            UserInfo.getUserId()  // Propriétaire = utilisateur courant
        );

        // IDs "utilisateurs de l'équipe" = juste l'utilisateur courant
        Set<Id> fakeUserIds3 = null;

        // Création des mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IUserService mockUserService = (IUserService) mocks.mock(IUserService.class);
        IOrderSelector mockOrderSelector = (IOrderSelector) mocks.mock(IOrderSelector.class);

        // Configuration des mocks
        mocks.startStubbing();
        mocks.when(mockUserService.getMyTeamUsersId()).thenReturn(fakeUserIds3);
        mocks.stopStubbing();

        // Enregistre les mocks
        Application.Service.setMock(IUserService.class, mockUserService);
        Application.Selector.setMock(mockOrderSelector);

        Test.startTest();
        MyTeamOrdersController controller;
        try {
            controller = new MyTeamOrdersController();
        } catch(Exception e) {
            System.debug('Exception : ' + e.getMessage());
        }
        Test.stopTest();

        System.AssertEquals(0, controller.teamOrders.size(), 'Pas de teamOrders car erreur');
        System.AssertEquals(0, controller.sumOrders, 'Pas de sumOrders car erreur');

    }

}
