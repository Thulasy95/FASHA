@isTest
private class UserServiceTest {

    @isTest
    static void testGetMyTeamUsersIdSingleUser() {
        // Arrange : créer un rôle partagé
        UserRole testRole = new UserRole(Name = 'TeamRole');
        insert testRole;

        // Créer un utilisateur avec ce rôle
        User u = TestDataFactory.createUser('uts', 'usertestservice', 'TeamRole', testRole);

        System.runAs(u) {
            Test.startTest();
            // Act : appel du service
            Set<Id> result = UserService.newInstance().getMyTeamUsersId();
            Test.stopTest();

            // Assert : le Set doit contenir l’utilisateur courant
            System.assert(result.contains(u.Id), 'Le Set doit contenir l’utilisateur courant');
            System.assert(!result.isEmpty(), 'Le Set ne doit pas être vide');
            System.assertEquals(1, result.size(), 'Le Set doit contenir exactement 1 utilisateur');
        }
    }

    @isTest
    static void testGetMyTeamUsersIdMultipleUsers() {
        // Arrange : créer un rôle partagé
        UserRole sharedRole = new UserRole(Name = 'SharedRole');
        insert sharedRole;

        // Créer deux utilisateurs avec le même rôle
        User u1 = TestDataFactory.createUser('u1s', 'serviceuser1', 'SharedRole', sharedRole);
        User u2 = TestDataFactory.createUser('u2s', 'serviceuser2', 'SharedRole', sharedRole);

        System.runAs(u1) {
            Test.startTest();
            // Act : appel du service
            Set<Id> result = UserService.newInstance().getMyTeamUsersId();
            Test.stopTest();

            // Assert : les deux utilisateurs actifs doivent être présents
            System.assert(result.contains(u1.Id), 'Le Set doit contenir le user courant');
            System.assert(result.contains(u2.Id), 'Le Set doit contenir l’autre user du même rôle');
            System.assertEquals(2, result.size(), 'Le Set doit contenir exactement 2 utilisateurs actifs du même rôle');
        }
    }
}
