@isTest
private class OrderSelectorTest {

    @isTest
    static void testSelectById() {

        // 1. Créer l’utilisateur (setup object)
        User owner = TestDataFactory.createUser('ord', 'orderowner', 'OrderRole', null);

        // 2. Utiliser System.runAs pour eviter l'erreur MIXED_DML_OPERATION
        System.runAs(owner) {

            Account acc = new Account(Name = 'Test Account');
            insert acc;

            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                1, acc.Id, 'Draft', 50, 1, owner.Id
            );
            Order o = orders[0];

            Test.startTest();
            List<Order> results = OrderSelector.newInstance().selectById(new Set<Id>{o.Id});
            Test.stopTest();

            System.assertEquals(1, results.size(), 'Une seule commande doit être trouvée');
            System.assertEquals(o.Id, results[0].Id, 'La commande retournée doit correspondre');
        }
    }


    @isTest
    static void testSelectOrdersByStatusAndUsersIdFound() {
        User owner = TestDataFactory.createUser('own', 'orderowner2', 'OrderRole2', null);

        System.runAs(owner) {
            Account acc = new Account(Name = 'Test Account 2');
            insert acc;

            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                2, acc.Id, 'Activated', 100, 1, owner.Id
            );

            Test.startTest();
            List<Order> results = OrderSelector.newInstance()
                .selectOrdersByStatusAndUsersId('Activated', new Set<Id>{owner.Id});
            Test.stopTest();

            System.assertEquals(2, results.size(), 'Les 2 commandes doivent être récupérées');
            System.assertEquals('Activated', results[0].Status , 'Le statut de la commande est incorrect');
        }
    }


    @isTest
    static void testSelectOrdersByStatusAndUsersIdNotFound() {
        User owner = TestDataFactory.createUser('own3', 'orderowner3', 'OrderRole3', null);

        System.runAs(owner) {
            Account acc = new Account(Name = 'Test Account 3');
            insert acc;

            TestDataFactory.createOrdersWithOrderItems(
                1, acc.Id, 'Draft', 30, 1, owner.Id
            );

            Test.startTest();
            List<Order> results = OrderSelector.newInstance()
                .selectOrdersByStatusAndUsersId('Activated', new Set<Id>{owner.Id});
            Test.stopTest();

            System.assertEquals(0, results.size(), 'Aucune commande ne doit être retournée');
        }
    }


    @isTest
    static void testSelectOrdersByStatusAndUsersIdLimit() {
        User owner = TestDataFactory.createUser('own4', 'orderowner4', 'OrderRole4', null);

        System.runAs(owner) {
            Account acc = new Account(Name = 'Test Account 4');
            insert acc;

            // Création de 150 commandes
            TestDataFactory.createOrdersWithOrderItems(
                150, acc.Id, 'Activated', 200, 1, owner.Id
            );

            Test.startTest();
            List<Order> results = OrderSelector.newInstance()
                .selectOrdersByStatusAndUsersId('Activated', new Set<Id>{owner.Id});
            Test.stopTest();

            System.assertEquals(100, results.size(), 'La requête doit être limitée à 100 enregistrements');
        }
    }
}
