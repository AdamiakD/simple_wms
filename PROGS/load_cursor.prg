Procedure load_cursor
	Lparameters Table
	Local Cursor, currrec
	
	Wait Window 'Aktualizacja stanów magazynowych...' Nowait

	Cursor = 'a' + Alltrim(Table)
	currrec = 0

	If Used(Table)
		Select (Table)
		Use
	Endif

	If Used(Cursor)
		Select (Cursor)
		currrec = Recno(Cursor)
		Use
	Endif

*!*		nStatus = 0
*!*		nTimes = 0
*!*		Do While nStatus = 0 and nTimes < 5000
*!*			Try
*!*				Select * From 'DATA\' + (Table) + '.dbf' Where !Deleted() Into Cursor (Cursor) Readwrite
*!*				Select (Cursor)
*!*				nStatus = 1
*!*			Catch To loTrapMsg
*!*			Endtry
*!*			nTimes = nTimes + 1
*!*		EndDo

	Do progs/qsql with 'select * from ' + (Table), 'simple_wms', (Cursor)

	If Used((Cursor))
		If Alltrim(Upper(Table)) == 'PROJECTS'
			Select aprojects
			replace all p_status with Strtran(p_status, 'Zako?czony', 'Zakoñczony') 
		EndIf 
		
		If Alltrim(Upper(Table)) == '_MAIN'
			nStatus = 0
			nTimes = 0
			Do While nStatus = 0 and nTimes < 5000
				Try
					Update a_main Set a_main.io_marker = 'Przyjêcie' Where a_main.in_out = 1
					Update a_main Set a_main.io_marker = 'Wydanie' Where a_main.in_out = 0
					
					Do progs/qsql with 'select * from materials', 'simple_wms', 'materials'
					Update a_main Set a_main.Name = materials.m_name From a_main inner Join 'materials' On a_main.name_id = materials.m_id
					Update a_main Set a_main.Weight = materials.m_weight From a_main inner Join 'materials' On a_main.name_id = materials.m_id
					Select materials
					Use 
					
					Do progs/qsql with 'select * from units', 'simple_wms', 'units'
					Update a_main Set a_main.unit_type = units.u_name From a_main inner Join 'units' On a_main.u_type_id = units.u_id
					Update a_main Set a_main.pack_type = units.u_name From a_main inner Join 'units' On a_main.p_type_id = units.u_id
					Select units
					Use 
					Do progs/qsql with 'select * from projects', 'simple_wms', 'projects'
					Update a_main Set a_main.Project = projects.p_name From a_main inner Join 'projects' On a_main.project_id = projects.p_id
					Select projects
					Use 
					Do progs/qsql with 'select * from clients', 'simple_wms', 'clients'
					Update a_main Set a_main.client = clients.c_name From a_main inner Join 'clients' On a_main.client_id = clients.c_id
					Update a_main Set a_main.carrier = clients.c_name From a_main inner Join 'clients' On a_main.carrier_id = clients.c_id
					Select clients
					Use 
					nStatus = 1
				Catch To loTrapMsg
				Endtry
				nTimes = nTimes + 1
			EndDo
		Endif

		If Used(Table)
			Select (Table)
			Use
		EndIf

		Select (Cursor) 
	Else 
		MessageBox('Niespodziewany blad. Uruchom ponownie program...')
		Clear Events 
		On Shutdown 
		Quit 
	EndIf 
Wait clear 
Endproc