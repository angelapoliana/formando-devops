locals {
    nome = "Angela de Jesus"
    current_timestamp  = timestamp()
    data = formatdate("YYYY-MM-DD", local.current_timestamp)
    div = 15
    calc = [for x in range(1,101) : x if x%local.div == 0]
    result_div = jsonencode(local.calc)
}
