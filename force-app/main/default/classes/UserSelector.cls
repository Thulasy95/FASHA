public with sharing class UserSelector extends fflib_SObjectSelector implements IUserSelector {

    public static IUserSelector newInstance(){
		return (IUserSelector) Application.Selector.newInstance(User.SObjectType);
	}

    // Liste des champs à récupérer par défaut dans les requêtes SOQL sur l'objet User
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            User.Id,
            User.Name,
            User.Email,
            User.UserName,
            User.UserRoleId
        };
    }
    
    public Schema.SObjectType getSObjectType(){
        return User.sObjectType;
    }

    public List<User> selectById(Set<ID> idSet) {
        return (List<User>) selectSObjectsById(idSet);
    }

    // Retourne l'Id du rôle de l' utilisateur connecté 
    public Id currentUserRoleId(){

        Id currentUserId = UserInfo.getUserId();

        fflib_QueryFactory qf = newQueryFactory();
        qf.selectFields(getSObjectFieldList());
        qf.setCondition('Id = :currentUserId');
        qf.setLimit(1);

        User user =  (User) Database.query(qf.toSOQL());

        return user.UserRoleId;
    }

    // Retourne l'ensemble des Ids des utilisateurs actifs ayant un rôle donné
    public Set<Id> selectActiveUsersIdByRoleId (Id roleId) {
        
        Set<Id> userIds = new Set<Id>();

        fflib_QueryFactory qf = newQueryFactory();
        qf.selectFields(getSObjectFieldList());
        qf.setCondition('IsActive = true AND UserRoleId = :roleId');
        qf.setLimit(100);

        List<User> users = (List<User>) Database.query(qf.toSOQL());

        for (User u : users) {
            userIds.add(u.Id);
        }

        return userIds;

    }
        
}