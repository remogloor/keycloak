var attributes = {};

user.getRoleMappings().forEach(function(roleModel) {
    var map = roleModel.getAttributes();
    map.forEach(function(key, value){
        attributes[key] = value;
    }); 
});

exports = attributes;
