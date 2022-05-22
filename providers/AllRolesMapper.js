var roles = [];

function processRole(roleModel, roleSet) {
    var name = roleModel.getName();
    if (name.startsWith("HW_")) roleSet.push(name);
    
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

var result = java.lang.reflect.Array.newInstance(java.lang.String.class, roles.length);
for (var i = 0; i < roles.length; i++) result[i] = roles[i];

exports = result;
