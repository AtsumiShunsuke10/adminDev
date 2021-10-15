public with sharing class CaseTriggerHandler {
    public void OnBeforeUpdate(List<Case> cases) {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'システム管理者'];
        Map<Id, Group> queue = new Map<Id, Group>([SELECT Id FROM Group WHERE Type = 'Queue']);
        Map<Id, User> users = new Map<Id, User>([SELECT Id, UserRoleId, ProfileId FROM User]);
        Map<Id, UserRole> roles = new Map<Id, UserRole>([SELECT Id, ParentRoleId FROM UserRole]);

        if(systemAdminProfile.Id!=UserInfo.getProfileId()) {
            for(Case c : cases) {
                User owner = users.get(c.ownerId);
                if(!queue.isEmpty() && queue.get(c.ownerId)==null && systemAdminProfile.Id!=owner.ProfileId) {
                    Id roleId = owner.UserRoleId;
                    List<String> parentRoles = new List<String>();
                    while(roleId!=null) {
                        UserRole role = roles.get(roleId);
                        if(role.parentRoleId!=null) {
                            parentRoles.add(role.ParentRoleId);
                        }
                        roleId = role.ParentRoleId;
                    }
                    if(!parentRoles.contains(UserInfo.getUserRoleId())) {
                        if(c.ownerId!=Userinfo.getUserId()) {
                            c.addError('所有者が異なるため更新不可');
                        }
                    }
                }
            }
        }
    }
}