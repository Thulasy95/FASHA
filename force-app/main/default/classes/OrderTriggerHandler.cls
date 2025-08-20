public class OrderTriggerHandler extends fflib_SObjectDomain {

    public OrderTriggerHandler(List<Order> sObjectList) {
        // Les classes de domaine sont initialisées avec des listes pour imposer la gestion en masse (bulkification) dans l'ensemble du code.
        super(sObjectList);
    }

    public override void onApplyDefaults() {
        //Attribue automatiquement le statut "Draft" à une commande (Order) si aucun statut n’a été défini.
        for(Order ord : (List<Order>) this.records) {
            if(ord.Status == null) {
                ord.Status = 'Draft';
            }
        }
    }

    public override void onValidate() {
        //Empêche l'enregistrement d'une commande si aucun compte (AccountId) n'y est associé
        for(Order ord : (List<Order>) this.records) {
            if(ord.AccountId == null) {
                ord.AccountId.addError('Un compte est requis pour une commande.');
            }
        }
    }

    public override void onValidate(Map<Id, SObject> currentRecords) {
        //Empêche les utilisateurs ou les processus Apex de modifier le statut d'une commande une fois qu’elle est Activated
        for(Order ord : (List<Order>) this.records) {
            Order currentOrder = (Order) currentRecords.get(ord.Id);
            if(currentOrder.Status == 'Activated' && ord.Status != currentOrder.Status) {
                ord.Status.addError('Vous ne pouvez pas modifier une commande activée.');
            }
        }
    }

    public override void onBeforeInsert() {

        updateNetAmount();

    }

    public override void onBeforeUpdate(Map<Id,SObject> oldRecords) {

        updateNetAmount();

    }

    public override void onAfterInsert() {

        updateSalesRevenueOnAccount();

    }

    public override void onAfterUpdate(Map<Id,SObject> oldRecords) {

        updateSalesRevenueOnAccount();

    }

    public override void onAfterDelete() {

        updateSalesRevenueOnAccount();

    }

    private void updateSalesRevenueOnAccount() {

        Set<Id> accountIds = new Set<Id>();
        for(Order ord : (List<Order>) this.records) {
            if(ord.Status == 'Ordered' && ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }
        
        if(!accountIds.isEmpty()){
            IAccountService accountService = (IAccountService) Application.Service.newInstance(IAccountService.class);
            accountService.updateSalesRevenue(accountIds);
        }       

    }

    private void updateNetAmount() {

        IOrderService orderService = (IOrderService) Application.Service.newInstance(IOrderService.class);
        orderService.updateNetAmount((List<Order>) this.records);
		
    }


    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrderTriggerHandler(sObjectList);
        }
    }        

}
