handleLoad = () => {
    window.addEventListener("message", function (event) {  
        switch(event.data.type) {
            case "loadData":
                JOB.LoadJobs(event.data.JobsData)
        }
    })

    let JOB = []

    JOB.ExecuteCallback = async function(name, data) {
        return new Promise(resolve => {
            $.post(`https://${GetParentResourceName()}/`+name, JSON.stringify({data: data}), function(result) {
                resolve(JSON.parse(result))
            })
        })
    }

   

    JOB.LoadJobs = (JobsData) => {
        Object.entries(JobsData).forEach(([key, value]) => {
            console.log(key + ' ' + value)
            console.log(JSON.stringify(value['label']))
            $(".edit-wrapper").append(`
            
                <div id="${key}" class="job-wrapper">
                    <a href="#homeSubmenu-${key}" id="homeSubmenu-${key}" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle text" style="color: black; font-size: .7vw;"><strong>${key}</strong></a>
                    <ul class="collapse list-unstyled" id="homeSubmenu-${key}">
                        <li class="item-list">
                            <a href="#homeSubmenu-ranks-${key}" id="homeSubmenu-ranks-${key}" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle text" style="color: black; font-size: .7vw;">Ranks (Coming soon)</a>
                            <ul class="collapse list-unstyled" id="homeSubmenu-ranks-${key}">
                            </ul>
                            <a href="#homeSubmenu-markers-${key}" id="homeSubmenu-markers-${key}" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle text" style="color: black; font-size: .7vw;">Markers</a>
                            <ul class="collapse list-unstyled" id="homeSubmenu-markers-${key}">
                                <li class="item-list">
                                    <div class="edit-ranks" id="edit-markers-${key}">
                                    <div class="save" id="save-markers-${key}"><span class="text" style="font-size: .7vw;">Save</span></div> <div class="save" id="add-markers-${key}"><span class="text" style="font-size: .7vw;">Add</span></div>                                                            
                                    </div>
                                </li>
                            </ul>
                            <a href="#homeSubmenu-vehicles-${key}" id="homeSubmenu-vehicles-${key}" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle text" style="color: black; font-size: .7vw;">Vehicles</a>
                            <ul class="collapse list-unstyled" id="homeSubmenu-vehicles-${key}">
                                <li class="item-list">
                                    <div class="edit-ranks">
                                        <div class="rank-num" id="markers-1">
                                            <input class="text" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="Vehicle" value="Zentorno"></input>
                                        </div>          
                                        <div class="save" style="background-color: blueviolet;"><span class="text" style="font-size: .4vw;">Add a vehicle</span></div> 
                                        <div class="save"><span class="text" style="font-size: .7vw;">Save</span></div>                              
                                    </div>
                                </li>
                            </ul>
                            <a class="option">Shop</a>
                            <a class="option">Options</a>
                        </li>
                    </ul>
                </div>            
            `)
            $(`#add-markers-${key}`).on("click", async () => {
                markers++
                $(`#edit-markers-${key}`).append(`
                    <div class="rank-num" id="markers-${markers}">
                        <input class="text" id="markere-${markers}-x" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="X" value="0"></input>
                        <input class="text" id="markere-${markers}-y" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="Y" value="0"></input>
                        <input class="text" id="markere-${markers}-z" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="Z" value="0"></input>
                        <select num="${markers}" id="markere-${markers}-selected" style="width: 2vw;">
                            <option value="armory">Armario</option>
                            <option value="getvehs">Sacar coches</option>
                            <option value="savevehs">Guardar vehículos</option>
                            <option value="boss">Jefe</option>
                            <option value="shop">Tienda</option>
                        </select>
                        <div class="button actualcoords" style="position: relative;" num="${markers}" id="markere-${markers}-button" style="background-color: red;"><span class="text" style="font-size: .4vw;">Actual coords</span></div>
                        <div class="button actualcoords" style="position: relative;" num="${markers}" id="markeredelete-${markers}-button" style="background-color: red;"><span class="text" style="font-size: .4vw;">Delete</span></div>
                    </div>  
                `)
                let coords = await JOB.ExecuteCallback("getCoords")
                let axis = ['x', 'y', 'z']
                axis.forEach((ax) => {
                    $(`#markere-${markers}-${ax}`).val(coords[ax])
                })
                $(`#markere-${markers}-button`).on("click", async function() {
                    let coords = await JOB.ExecuteCallback("getCoords")
                    let actualMarker = $(this).attr("num")
                    let axis = ['x', 'y', 'z']
                    axis.forEach((ax) => {
                        $(`#markere-${actualMarker}-${ax}`).val(coords[ax])
                    })
                })
                $(`#markeredelete-${markers}-button`).on("click", function() {
                    let actualMarker = $(this).attr("num")
                    $(`#markers-${actualMarker}`).remove()
                })
            })
            let markers = 0
            value['points'].forEach((val) => {
                markers++
                $(`#edit-markers-${key}`).append(`
                    <div class="rank-num" id="markers-${markers}">
                        <input class="text" id="markere-${markers}-x" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="X" value="${val.x}"></input>
                        <input class="text" id="markere-${markers}-y" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="Y" value="${val.y}"></input>
                        <input class="text" id="markere-${markers}-z" style="color: black; text-align: center; width: 50%; font-size: 0.8vw;" placeholder="Z" value="${val.z}"></input>
                        <select num="${markers}" id="markere-${markers}-selected" style="width: 2vw;">
                            <option value="armory">Armario</option>
                            <option value="getvehs">Sacar coches</option>
                            <option value="savevehs">Guardar vehículos</option>
                            <option value="boss">Jefe</option>
                            <option value="shop">Tienda</option>
                        </select>
                        <div class="button actualcoords" style="position: relative;" num="${markers}" id="markere-${markers}-button" style="background-color: red;"><span class="text" style="font-size: .4vw;">Actual coords</span></div>
                        <div class="button actualcoords" style="position: relative;" num="${markers}" id="markeredelete-${markers}-button" style="background-color: red;"><span class="text" style="font-size: .4vw;">Delete</span></div>
                    </div>  
                `)
                $(`#markere-${markers}-selected`).val(val.selected);
                $(`#markere-${markers}-button`).on("click", async function() {
                    
                    let coords = await JOB.ExecuteCallback("getCoords")
                    let actualMarker = $(this).attr("num")
                    let axis = ['x', 'y', 'z']
                    axis.forEach((ax) => {
                        $(`#markere-${actualMarker}-${ax}`).val(coords[ax])
                    })
                })
                $(`#markeredelete-${markers}-button`).on("click", function() {
                    let actualMarker = $(this).attr("num")
                    $(`#markers-${actualMarker}`).remove()
                })
            })

            $(".dropdown-toggle").on("click", function() {
                var isExpanded = $(this).attr("aria-expanded")
                let that = this
                if (isExpanded === "false") {
                    
                } else {
                    setTimeout(() => {
                        $(that).removeClass("collapse")
                    }, 358);
                }
            })


            $(`#save-markers-${key}`).on("click", function() {
                let Data = []
                for (var i = 1; i <= markers; i++) {
                    if ($(`#markere-${i}-x`).val()) {
                        let toInsert = {
                            Job: key,
                            Type: "updateMarkers",
                            x: $(`#markere-${i}-x`).val(),
                            y: $(`#markere-${i}-y`).val(),
                            z: $(`#markere-${i}-z`).val(),
                            selected: $(`#markere-${i}-selected`).val(),
                        }
                        Data.push(toInsert)
                    }
                }
                JOB.ExecuteCallback("updateInfo", Data)
            })


        })
    }



}

window.addEventListener("load", this.handleLoad)