public interface IOrderService {

    void updateNetAmount(List<Order> orders);
    Decimal calculateNetAmount(Order ord);

}