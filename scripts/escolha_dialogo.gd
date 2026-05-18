extends Resource
class_name EscolhaDialogo

var texto : String
var tags_necessarias : Array[String]
var tags_proibidas : Array[String]
var tags_adicionadas : Array[String]
var proxima_arvore : String = ""

func _init(_texto : String, _tags_necessarias : Array[String], _tags_proibidas : Array[String], _tags_adicionadas : Array[String], _proxima_arvore : String) -> void:
    texto = _texto
    tags_necessarias = _tags_necessarias
    tags_proibidas = _tags_proibidas
    tags_adicionadas = _tags_adicionadas
    proxima_arvore = _proxima_arvore