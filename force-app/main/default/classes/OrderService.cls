public with sharing class OrderService implements IOrderService {

    public static IOrderService newInstance(){
        return (IOrderService) Application.Service.newInstance(IOrderService.class);
    }

    public void updateNetAmount(List<Order> orders) {

        //Récupère le domain class
		IOrderDomain orderDomain = (IOrderDomain) Application.Domain.newInstance( orders );

        //Execute la logique métier dans la domain class
		orderDomain.updateNetAmount();

    }

    public Decimal calculateNetAmount(Order ord) {

        Decimal netAmount = 0;

        if( ord.TotalAmount != null && ord.ShipmentCost__c != null) {
            netAmount = ord.TotalAmount - ord.ShipmentCost__c;
        }

        return netAmount;
        
    }

}