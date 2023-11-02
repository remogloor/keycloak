var roles = [];

function processRole(roleModel, roleSet) {
    var name = roleModel.getName();
    if (name.startsWith("HW_")) roleSet.push(name);
    
    if (roleModel.isComposite()) {
        roleModel.getCompositesStream().forEach(function(roleModel) {
            roleSet = processRole(roleModel, roleSet);
        });
    }
    
    return roleSet;
}

if(token instanceof Java.type("org.keycloak.representations.AccessToken")){
  user.getGroupsStream().forEach(function(groupModel) {    
      groupModel.getRoleMappingsStream().forEach(function(roleModel) {
          roles = processRole(roleModel, roles);
      });
  });

  user.getRoleMappingsStream().forEach(function(roleModel) {
      roles = processRole(roleModel, roles);
  });

  if (roles.length > 0) {
   token.setScope(token.getScope() + " " + roles.join(" "));
  }    
}



