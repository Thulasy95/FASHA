@IsTest
private class AccountServiceTest {

    @IsTest
    static void testUpdateSalesRevenue() {

        List<Account> accounts = TestDataFactory.createAccounts(3);
        insert accounts;

        Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();

        // Création des mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountDomain domainMock = (IAccountDomain) mocks.mock(AccountDomain.class);
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountSelector selectorMock = (IAccountSelector) mocks.mock(IAccountSelector.class);

        // Configuration des mocks
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(selectorMock.selectSObjectsById(accountIds)).thenReturn(accounts);
        mocks.when(domainMock.getType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(domainMock.getRecords()).thenReturn(accounts);
        mocks.stopStubbing();

        // Enregistre les mocks
        Application.UnitOfWork.setMock(unitOfWorkMock);
        Application.Domain.setMock((fflib_ISObjectDomain) domainMock);
        Application.Selector.setMock(selectorMock);

        IAccountService service = AccountService.newInstance();

        Test.startTest();
        service.updateSalesRevenue(accountIds);
        Test.stopTest();

        // Assertions
        //On vérifie l'appel du selector pour récupérer les comptes, 
        ((IAccountSelector) mocks.verify(selectorMock)).selectSObjectsById(accountIds);
        //et l'unit of work doit enregistrer et valider les changements
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).registerDirty(accounts);
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).commitWork();

        System.assertEquals(3, domainMock.getRecords().size(), 'Le domain doit retourner les 3 comptes');

    }

    @IsTest
    static void testCalculateSalesRevenue() {

        User owner = TestDataFactory.createUser('calc', 'calcowner', 'AccountRole', null);

        System.runAs(owner) {
            Account acc = new Account(Name='Test Account Calc');
            insert acc;

            // Création des commandes avec OrderItems via TestDataFactory
            List<Order> orders = TestDataFactory.createOrdersWithOrderItems(
                2,          // nombre de commandes
                acc.Id,     // accountId
                'Draft',    // status de départ
                0,          // shipmentCost
                1,          // nombre d'OrderItems
                owner.Id
            );

            // Mise à jour du statut pour que certaines commandes soient comptabilisées
            orders[0].Status = 'Ordered';
            orders[1].Status = 'Activated';
            update orders;

            // Requery pour forcer le calcul de TotalAmount
            orders = [SELECT Id, AccountId, TotalAmount, Status FROM Order WHERE Id IN :orders ];

            // Obtenir le service et calculer le chiffre d'affaires
            IAccountService service = AccountService.newInstance();

            Test.startTest();
            Map<Id, Decimal> result = service.calculateSalesRevenue(new List<Account>{acc});            
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
            System.assertEquals(1, result.size(), 'Une seule entrée pour le compte doit exister');

            // Récupérer le total des OrderItems pour vérification
            Decimal expectedTotal = 0;
            for (Order o : orders) {
                if(o.Status == 'Ordered' || o.Status == 'Activated') {
                    expectedTotal += o.TotalAmount;
                }
            }

            System.assertEquals(expectedTotal, result.get(acc.Id), 'Le chiffre d’affaires doit correspondre à la somme des TotalAmounts des commandes');
        }
    }
}