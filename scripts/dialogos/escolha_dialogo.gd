extends Resource
class_name EscolhaDialogo

var texto : String
var tags_necessarias : Array[String]
var tags_proibidas : Array[String]
var tags_adicionadas : Array[String]
var tags_necessarias_personagem : Array[String]
var tags_proibidas_personagem : Array[String]
var tags_adicionadas_personagem : Array[String]
var proxima_arvore : String = ""

func _init(_texto : String, _tags_necessarias : Array[String], _tags_proibidas : Array[String], _tags_adicionadas : Array[String], _tags_necessarias_personagem : Array[String], _tags_proibidas_personagem : Array[String], _tags_adicionadas_personagem : Array[String], _proxima_arvore : String) -> void:
    texto = _texto
    tags_necessarias = _tags_necessarias
    tags_proibidas = _tags_proibidas
    tags_adicionadas = _tags_adicionadas
    tags_necessarias_personagem = _tags_necessarias_personagem
    tags_proibidas_personagem = _tags_proibidas_personagem
    tags_adicionadas_personagem = _tags_adicionadas_personagem
    proxima_arvore = _proxima_arvore