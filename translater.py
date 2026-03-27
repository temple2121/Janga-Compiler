import sys
import subprocess

def translate_file(source):
	if source[-1]=='debug':
		print(source)
	file = ''
	commented_out = 1
	for i, t in enumerate(source):
		if '//' in t:
			commented_out*=-1

		if commented_out==1:
			if t=='stop':
				file+='0,'
			if t=='num':
				file+='1,'
				file+=str(source[i+1])+','
			if t=='trash':
				file+='2,'
				file+=str(source[i+1])+','
			if t=='print':
				file+='3,'
				if source[i+1]!='-1':
					file+=str(ord(source[i+1]))+','
				else:
					file+='-1,'
			if t=='printStr':
				file+='4,'
				for word in source[i+1:]:
					for char in word:	
						if char != '|':
							file+=str(ord(char))+','
						else:
							file+='0,'
							break_str_find = True
							break
					else:
						file+='32,'
						continue
					break

			if t=='newLine':
				file+='4,10,0,'
			if t=='input':
				file+='5,'
			if t=='define':
				file+='6,'
				file+=str(ord(source[i+1]))+','
				file+=str(source[i+2])+','
			if t=='var':
				file+='7,'
				file+=str(ord(source[i+1]))+','
			if t=='->':
				file+='8,'
				file+=str(ord(source[i+1]))+','
			if t=='loop':
				file+='9,'
				file+=str(ord(source[i+1]))+','
			if t=='check':
				file+='10,'
			if t=='if':
				file+='11,'
				file+=str(ord(source[i+1]))+','
				file+=source[i+2]+','
			if t=='end':
				file+='12,12,'
			if t=='+':
				file+='13,'
			if t=='*':
				file+='14,'
			if t=='-':
				file+='15,'
			if t=='/':
				file+='16,'
			if t=='%':
				file+='17,'
			if t=='>':
				file+='19,'
			if t=='!=':
				file+='21,'



	return file

with open(sys.argv[1]) as f:
	source = str.split(f.read())
translated = translate_file(source)

if source[-1]=='debug':	
	print('token length: '+str(len(translated.split(','))-1))
	print('raw tokens: '+translated)
	testing_token = 0
	print('token at '+str(testing_token)+': '+str(source[testing_token]))


with open("NASMfile.asm") as f:
	interpreter_file = f.read()

interpreter_file = interpreter_file.replace(
    "PLACEHOLDER",
    "program: dd " + translated + "0"
)

with open("out.asm", "w") as f:
    f.write(interpreter_file)

subprocess.run(["nasm", "-f", "macho64", "out.asm", "-o", "out.o"]) #assembly into machine code
subprocess.run(["clang", "-arch", "x86_64", "-w", "-o", "out", "out.o"]) #machine code into binary
if not 'input' in source:
	subprocess.run(["./out"])	#run that bad boy
else:
	subprocess.run([
    "open", "-a", "Terminal", "./out"])
