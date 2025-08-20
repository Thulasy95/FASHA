public with sharing class MyTeamOrdersController {
    
    //"private set" Empêche une modification involontaire depuis la page.
    public Decimal sumOrders { get; private set; }
    public List<Order> teamOrders { get; private set; }

    public MyTeamOrdersController() {
        try {
            calculateTeamOrderSum();
            displayTeamOrders();
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Erreur lors du chargement des données : ' + e.getMessage()));
            sumOrders = 0;
            teamOrders = new List<Order>();
        }
    }


    private void calculateTeamOrderSum() {

        sumOrders = 0;

        // Obtient les Ids des utilisateurs de l'équipe via le service utilisateur
        IUserService userService = (IUserService)Application.Service.newInstance(IUserService.class);
        Set<Id> userIds = userService.getMyTeamUsersId();
        System.debug('usersIds :' + userIds);

        // Récupère uniquement les commandes que l'utilisateur est autorisé à voir et calcule la somme des commandes.
        AggregateResult groupedResult = [SELECT SUM(TotalAmount) total FROM Order WHERE Status = 'Ordered' AND OwnerId IN :userIds];
        
        //Évite une erreur si aucune commande n’est trouvée.
        sumOrders = (groupedResult != null && groupedResult.get('total') != null) ? (Decimal) groupedResult.get('total') : 0 ;
    
    }


    private void displayTeamOrders() {

        IUserService userService = (IUserService)Application.Service.newInstance(IUserService.class);
        Set<Id> userIds = userService.getMyTeamUsersId();

        // Récupère les commandes de l'équipe, avec un statut 'Ordered' et triées par date 
        IOrderSelector orderSelector = (IOrderSelector)Application.Selector.newInstance(Order.SObjectType);
        teamOrders = orderSelector.selectOrdersByStatusAndUsersId('Ordered', userIds);

    }

}
