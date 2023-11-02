var attributes = {};

function processRole(roleModel, attr) {
    var map = roleModel.getAttributes();
    map.forEach(function(key, value){
        attr[key] = value;
    });
    
    if (roleModel.isComposite()) {
        roleModel.getCompositesStream().forEach(function(roleModel) {
            attr = processRole(roleModel, attr);
        });
    }
    
    return attr;
}

user.getGroupsStream().forEach(function(groupModel) {
    var map = groupModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    });
    
    groupModel.getRoleMappingsStream().forEach(function(roleModel) {
        attributes = processRole(roleModel, attributes);
    });
});

user.getRoleMappingsStream().forEach(function(roleModel) {
    attributes = processRole(roleModel, attributes);
});

exports = attributes;
