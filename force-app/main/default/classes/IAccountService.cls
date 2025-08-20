public interface IAccountService {

    void updateSalesRevenue(Set<Id> accountIds);
    Map<Id,Decimal> calculateSalesRevenue(List<Account> accountsToUpdate);

}