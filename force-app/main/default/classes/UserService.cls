public with sharing class UserService implements IUserService {

    public static IUserService newInstance(){
		return (IUserService) Application.Service.newInstance(IUserService.class);
    }

    public Set<Id> getMyTeamUsersId() {

        // Récupére le rôle de l'utilisateur connecté
        IUserSelector userSelector = (IUserSelector)Application.Selector.newInstance(User.sObjectType);
        Id currentUserRoleId = userSelector.currentUserRoleId(); 

        // Récupére tous les utilisateurs de son équipe (avec même rôle)
        Set<Id> userIds = userSelector.selectActiveUsersIdByRoleId(currentUserRoleId);

        return userIds;

    }

}