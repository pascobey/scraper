class TransferElement {
    constructor(crumbPath, actionString) {
        this.element = document.createElement('span');
        this.element.id = "t-e";
        this.crumbPath = crumbPath;
        if (actionString===undefined) this.dataAction = "click";
        if (typeof(actionString)==='string') this.dataAction = "entry: '" + actionString + "'";
        this.element.textContent = this.dataAction + '|' + this.crumbPath;
        document.body.parentNode.appendChild(this.element);
    }
}
crumb = function(node) {
    return node.tagName.toLowerCase() + (node.id && "#"+node.id) || (""+node.classList && (" "+node.classList).replace(/ /g, "."));   
}
crumbPath = function(node) {
    return node.parentNode ? crumbPath(node.parentNode).concat(crumb(node)) : [];
}