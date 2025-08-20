public with sharing class AccountService implements IAccountService {

    // Méthode statique pour obtenir une instance de IAccountService
    public static IAccountService newInstance(){
      return (IAccountService) Application.Service.newInstance(IAccountService.class);
    }


    public void updateSalesRevenue(Set<Id> accountIds){

      //Création du Unit of Work (uow)
      fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

      //Récupère le domain class des comptes
		  IAccountDomain accountDomain = (IAccountDomain) Application.Domain.newInstance( accountIds );

      //Execute la logique métier dans la domain class
		  accountDomain.updateSalesRevenue();

      //enregistre les comptes modifiés dans l’unité de travail
		  uow.registerDirty(accountDomain.getRecords());

      //update sur les comptes
		  uow.commitWork();

    }

    public Map<Id,Decimal> calculateSalesRevenue(List<Account> accountsToUpdate){
      
      // Extraction des Ids des comptes depuis la liste
      Set<Id> accountIds = new Set<Id>();
      for (Account account : accountsToUpdate) {
        accountIds.add(account.Id);
      }

      // Requête d'agrégation SOQL qui récupère le total des montants des commandes par compte,
      // uniquement pour les commandes dont le statut est 'Ordered' ou 'Activated'
      List<AggregateResult> results = [SELECT AccountId, SUM(TotalAmount) total FROM Order WHERE AccountId IN: accountIds AND (Status = 'Ordered' OR Status = 'Activated') GROUP BY AccountId];

      Map<Id,Decimal> salesRevenueByAccountId = new Map<Id,Decimal>();

      for (AggregateResult result : results) {
        salesRevenueByAccountId.put( (Id)result.get('AccountId') , (Decimal)result.get('total') );
      }

      return salesRevenueByAccountId;

    }

}