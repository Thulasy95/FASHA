public class BatchAccountUpdateSalesRevenue implements Database.Batchable<sObject>, Database.Stateful {

    // Permet de tracer le nombre de comptes mis à jour
    @TestVisible
    private Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        //récupère les comptes avec au moins une commande 'Ordered' modifiée la semaine dernière
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Account ' +
            'WHERE Id IN (SELECT AccountId FROM Order '+
            'WHERE Status = \'Ordered\' AND LastModifiedDate = LAST_N_DAYS:7)'
        );

    }

    public void execute(Database.BatchableContext bc, List<Account> scope){

        if (scope.isEmpty()) {
            
            System.debug('Pas de compte avec la commande \'Ordered\' à mettre à jour');

        } else {
            
            // Extrait les Ids des comptes à traiter dans ce lot
            Set<Id> accountIds = new Set<Id>();
            for(Account acc : scope){
                accountIds.add(acc.Id);
                recordsProcessed ++;
            }

            IAccountService accountService = (IAccountService) Application.Service.newInstance(IAccountService.class);
            
            // Si on a des comptes, on appelle le service métier pour mettre à jour le chiffre d'affaires du compte
            if(!accountIds.isEmpty()){

                // Découpage en sous-lots de 100 Ids max pour éviter les limites DML
                //Tous les comptes du batch sont mis à jour, 100 par 100
                Integer batchSize = 100;
                List<Id> idsList = new List<Id>(accountIds);
                for(Integer i = 0; i < idsList.size(); i += batchSize) {

                    //Création d'un sous lot
                    List<Id> subListIds = new List<Id>();
                    Integer endIndex = Math.min(i + batchSize, idsList.size());
                    for (Integer j = i; j < endIndex; j++) {
                        subListIds.add(idsList[j]);
                    }                    
                    
                    accountService.updateSalesRevenue(new Set<Id>(subListIds));

                }
            }
        }

    }

    public void finish(Database.BatchableContext bc){
        // Trace dans les logs le nombre total de comptes mis à jour par le batch
        System.debug('Nombre total de comptes mis à jour : ' + recordsProcessed );
        
        //Récupérer les infos système du job dans AsyncApexJob
        AsyncApexJob job = [SELECT Id, 
            Status,             // Statut du Job
            NumberOfErrors,     // Nombre d'erreurs
            JobItemsProcessed,  // Nombre de lots traités
            TotalJobItems,      // Nombre total de lots traités
            CreatedBy.Email     // Utilisateur qui a lancé le batch
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        System.debug('AsynchApexJob batch : ' + job);

    }

}

