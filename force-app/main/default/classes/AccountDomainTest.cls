@IsTest
private class AccountDomainTest {

    @testSetup
    static void setupData() {
        // Crée 2 comptes via TestDataFactory et les insère
        List<Account> accounts = TestDataFactory.createAccounts(2);
        insert accounts;
    }

    @IsTest
    static void testUpdateSalesRevenueWithMock() {
        // Récupère les comptes insérés
        List<Account> accounts = [SELECT Id, SalesRevenue__c FROM Account];

        // Crée le domaine avec la liste de comptes
        AccountDomain domain = (AccountDomain) AccountDomain.newInstance(accounts);

        // Crée les mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountService mockAccountService = (IAccountService) mocks.mock(IAccountService.class);

        // Prépare les valeurs de SalesRevenue fictives
        Map<Id, Decimal> salesRevenueMap = new Map<Id, Decimal>();
        for(Account acc : accounts) {
            salesRevenueMap.put(acc.Id, 1000);
        }

        // Configure le mock pour retourner les valeurs fictives
        mocks.startStubbing();
        mocks.when(mockAccountService.calculateSalesRevenue(accounts)).thenReturn(salesRevenueMap);
        mocks.stopStubbing();

        // Enregistre le mock dans Application.Service
        Application.Service.setMock(IAccountService.class, mockAccountService);

        // Appelle la méthode updateSalesRevenue
        Test.startTest();
        domain.updateSalesRevenue();
        Test.stopTest();

        // Vérifie directement les objets en mémoire
        List<Account> updatedAccounts = domain.getAccounts();
        final Decimal expectedValue = 1000;
        for(Account acc : updatedAccounts) {
            System.assertEquals(expectedValue, acc.SalesRevenue__c,'SalesRevenue__c doit être égal à la valeur mockée');
        }
    }

    @IsTest
    static void testNewInstanceMethods() {

        List<Account> accounts = [SELECT Id FROM Account];

        // Test newInstance avec la liste
        IAccountDomain domainList = AccountDomain.newInstance(accounts);
        System.assertNotEquals(null, domainList, 'newInstance(List) doit retourner une instance');
        System.assertEquals(accounts.size(), domainList.getAccounts().size(), 'La taille des deux listes ne correspond pas');

        // Test newInstance avec Set<Id>
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : accounts) {
            accountIds.add(acc.Id);
        } 
        IAccountDomain domainSet = AccountDomain.newInstance(accountIds);
        System.assertNotEquals(null, domainSet, 'newInstance(Set) doit retourner une instance');
        System.assertEquals(accountIds.size(), domainSet.getAccounts().size(), 'La taille des deux listes ne correspond pas');

    }
}
