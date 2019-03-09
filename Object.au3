
#include <WinAPI.au3>
#include <AutoitObject_Internal.au3>


$user = IDispatch()

$user.email = "user@gmail.com"
$user.pass = 123123

$user.__defineGetter("login", Login)


$user.login()



Func Login($this)

	If $this.arguments.length = 0 Then Return False
	
	Local $user = $this.parent

	Local $status = $this.arguments.values[0]

	$email = $user.email
	$pass = $user.pass

	If $email = "xxx" And $pass = "xxx" Then

		Return "xxx"

	EndIf

	Return False
EndFunc
