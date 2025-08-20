@isTest
private class AccountSelectorTest {

    @isTest
    static void testSelectById() {
        // Arrange : création d’un compte de test
        Account acc = new Account(
            Name = 'Test Account',
            AccountNumber = 'ACC123',
            Active__c = 'true',
            Description = 'Compte pour test'
        );
        insert acc;

        // Act
        Test.startTest();
        List<Account> results = AccountSelector.newInstance().selectById(new Set<Id>{acc.Id});
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size(), 'Un seul compte doit être trouvé');
        System.assertEquals(acc.Id, results[0].Id, 'Le compte retourné doit correspondre à celui créé');
    }

}
