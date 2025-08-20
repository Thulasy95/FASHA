public class OrderDomain extends fflib_SObjectDomain implements IOrderDomain {
    
    public OrderDomain(List<Order> sObjectList) {
        super(sObjectList);
    }

    public static IOrderDomain newInstance(List<Order> recordList)
	{
		return (IOrderDomain) Application.Domain.newInstance(recordList);
	}

    // Retourne la liste des commandes
    public List<Order> getOrders() {
        return (List<Order>) getRecords();
    }

    public void updateNetAmount() {

        List<Order> ordersToUpdate = getOrders();

        if (ordersToUpdate == null || ordersToUpdate.isEmpty()) {
            return;
        }

        IOrderService orderService = (IOrderService) Application.Service.newInstance(IOrderService.class);

        for(Order ord : ordersToUpdate) {

            //On calcule calculatedNetAmount
            Decimal calculatedNetAmount = orderService.calculateNetAmount(ord);

            //Si le NetAmount est différent, 
            if ( ord.NetAmount__c != calculatedNetAmount) {
                //on affecte calculatedNetAmount au champs NetAmount de la commande
                ord.NetAmount__c = calculatedNetAmount;
            }

        }

    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OrderDomain(sObjectList);
        }
    }
    
}