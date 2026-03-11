import os

with os.scandir('/Users/sammyt/Code/Janga') as entries:
	for entry in entries:
		if '.obt' in entry.name:
			old_path = entry.path
			old_name = entry.name[0:-4]
			new_name = old_name+'.jan'
			new_path = os.path.join('/Users/sammyt/Code/Janga', new_name)
			os.rename(old_path,new_path)