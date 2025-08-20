public interface IUserSelector extends fflib_ISObjectSelector {

    List<User> selectById(Set<ID> idSet);
    Id currentUserRoleId();
    Set<Id> selectActiveUsersIdByRoleId (Id roleId);
   
}