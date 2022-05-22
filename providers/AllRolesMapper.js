var roles = new Set();

function processRole(roleModel, roleSet) {
    var name = roleModel.getName();
    if (name.startsWith("HW_") roleSet.add(name);
    
    if (roleModel.isComposite()) {
        roleModel.getComposites().forEach(function(roleModel) {
            roleSet = processRole(roleModel, roleSet);
        });
    }
    
    return roleSet;
}

user.getGroups().forEach(function(groupModel) {    
    groupModel.getRoleMappings().forEach(function(roleModel) {
        roles = processRole(roleModel, roles);
    });
});

user.getRoleMappings().forEach(function(roleModel) {
    roles = processRole(roleModel, roles);
});

exports = roles;
