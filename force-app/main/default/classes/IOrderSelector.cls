public interface IOrderSelector extends fflib_ISObjectSelector {

    List<Order> selectById(Set<ID> idSet);
    List<Order> selectOrdersByStatusAndUsersId(String status, Set<Id> usersIds);

}