@isTest
private class UserSelectorTest {

    @isTest
    static void testSelectById() {
        
        // Arrange : Création d’un utilisateur de test
        User u = TestDataFactory.createUser('tst', 'testselectbyid', 'TestRole1', null);
        
        // Act
        Test.startTest();
        List<User> results = UserSelector.newInstance().selectById(new Set<Id>{u.Id});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'Un seul utilisateur doit être trouvé');
        System.assertEquals(u.Id, results[0].Id, 'L’utilisateur retourné doit correspondre');
    }


    @isTest
    static void testCurrentUserRoleId() {

        // Arrange : Création d’un utilisateur de test avec un rôle
        User u = TestDataFactory.createUser('tcu', 'testcurrentrole', 'TestRole2', null);

        System.runAs(u) {
            // Act
            Test.startTest();
            Id roleId = UserSelector.newInstance().currentUserRoleId();
            Test.stopTest();

            // Assert
            System.assertEquals(u.UserRoleId, roleId, 'Le rôle retourné doit être celui du user courant');
        }
    }


    @isTest
    static void testSelectActiveUsersIdByRoleId() {
        // Arrange : Création d’un utilisateur actif avec un rôle
        User u = TestDataFactory.createUser('tsr', 'testselectrole', 'TestRole3', null);

        // Act
        Test.startTest();
        Set<Id> userIds = UserSelector.newInstance().selectActiveUsersIdByRoleId(u.UserRoleId);
        Test.stopTest();

        // Assert
        System.assert(userIds.contains(u.Id), 'Le set doit contenir l’utilisateur créé');
        System.assert(!userIds.isEmpty(), 'Le set ne doit pas être vide');
    }


    @isTest
    static void testSelectActiveUsersIdByRoleIdWithInactiveUser() {

        // Arrange : Création d’un utilisateur inactif avec un rôle
        User u = TestDataFactory.createInactiveUser('tia', 'testinactive', 'TestRoleInactive',null);

        // Act
        Test.startTest();
        Set<Id> userIds = UserSelector.newInstance().selectActiveUsersIdByRoleId(u.UserRoleId);
        Test.stopTest();

        // Assert : l’utilisateur ne doit pas être retourné car il est inactif
        System.assertEquals(0, userIds.size(), 'Un utilisateur inactif ne doit pas être dans les résultats');
    }

}
