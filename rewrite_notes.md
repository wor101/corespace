***Pages***
1. Index '/' - GET
2. Skills '/skills' - GET
    - category '/skills/:category' - GET 
        - skill '/skills/:category/:skill' - GET
3. Classes '/classes' - GET
    - class '/classes/:class' -GET
4. Crew '/crew' - GET
    - trader '/crew/:trader' -GET 
    - edit trader 'crew/:trader/edit_skills' - GET *there is extra params not being used '?edit_skills=Boston'
        - set skill 'crew/:trader/edit_skills' - POST
        - return to crew '/crew' - GET
    - delete trader '/crew/delete_trader' - POST
    - new trader '/crew/new_trader' - GET
        - create trader '/crew/new_trader' - POST
        - select skills '/crew/new_trader/select_skills' - GET
            - set skill '/crew/new_trader/select_skills' - POST
            - save trader '/crew/new_trader/save_trader' - POST