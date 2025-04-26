. (.\Openai.Class.Ps1)

$ai = [OpenAi]::new($env:apiKey, "gpt-4.1-mini")
$ai.addTool(".\tools\SafeInvoke.psd1")
$ai.addTool(".\tools\GetContent.psd1")
$ai.addTool(".\tools\GetChildItem.psd1")
$ai.addTool(".\tools\NewFile.psd1")

$ai.Body["instructions"] = "You are an helpful coding AI assistant with full acess to a powershell console."
$ai.GetTextResponse("run a command caleld Bogus-Command")
$ai.GetTextResponse("oh sorry tell me what the hostname is")
$ai.GetTextResponse("Did that work?")
$ai.GetTextResponse("put new files where they belong. make sure to check the directories you have access to and note their paths.")
$ai.GetTextResponse("can you update the go.main to generate a random password and grteet the user with the new password?")



