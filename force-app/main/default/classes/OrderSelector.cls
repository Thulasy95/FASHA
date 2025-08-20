public with sharing class OrderSelector extends fflib_SObjectSelector implements IOrderSelector {

    public static IOrderSelector newInstance(){
		return (IOrderSelector) Application.Selector.newInstance(Order.SObjectType);
	}
    
    // Retourne la liste des champs à récupérer par défaut dans les requêtes SOQL
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Order.Id,
            Order.Name,
            Order.Status,
            Order.AccountId,
            Order.OwnerId,
            Order.EffectiveDate,
            Order.TotalAmount,
            Order.OrderNumber
        };
    }

    public Schema.SObjectType getSObjectType(){
        return Order.sObjectType;
    }

    public List<Order> selectById(Set<ID> idSet) {
        return (List<Order>) selectSObjectsById(idSet);
    }

    // Sélectionne les commandes qui ont un statut donné et dont le propriétaire est dans un ensemble d'utilisateurs
    // Résultats triés par EffectiveDate décroissante, limite à 100 enregistrements
    public List<Order> selectOrdersByStatusAndUsersId(String status, Set<Id> usersIds){
        
        fflib_QueryFactory qf = newQueryFactory();
        qf.selectFields(getSObjectFieldList());
        qf.setCondition('Status = :status AND OwnerId IN :usersIds');
        qf.addOrdering(Order.EffectiveDate, fflib_QueryFactory.SortOrder.DESCENDING);
        qf.setLimit(100);
        return (List<Order>) Database.query(qf.toSOQL());

    }

}