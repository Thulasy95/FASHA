public interface IOrderDomain extends fflib_ISObjectDomain {

    List<Order> getOrders();  
    void updateNetAmount();

}