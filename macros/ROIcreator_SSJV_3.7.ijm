/* 
    ROIcreator_SSJV is an ImageJ macro developed to analyze different parameters
    at consequtive threshold levels,
    Copyright (C) 2015  Jorge Valero Gómez-Lobo and Silvia Sánchez Alonso

    ROIcreator_SSJV is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

   ROIcreator_SSJV is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//This macro has been developed by Dr Jorge Valero (jorge.valero@cnc.uc.pt). 
//If you have any doubt about how to use it, please contact me.

//License


Dialog.create("GNU GPL License");
Dialog.addMessage(" ROIcreator_SSJV Copyright (C) 2015 Jorge Valero Gomez-Lobo and Silvia Sanchez Alonso.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage(" ROIcreator_SSJV comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();

if (isOpen("Log")){
	selectWindow("Log");
	run("Close");
}

var procesada=false;

folderparam=getBoolean("Do you want to use a file containing the info of the folders (folderparam.txt)?");

if (folderparam==true){
	paramfile=File.openDialog("Select the txt file containing the information of the folders");
	dirgeneral=File.openAsString(paramfile);
	folder=split(dirgeneral, "\n");
	dirimage= folder[0];
	dirprocess=folder[1];
	dirNONprocess=folder[2];
	dirrois=folder[3];
	dirparam=folder[4];	
}

else{
	dirimage= getDirectory("Please, select the images folder");
	dirprocess=getDirectory("Please, select the processed images folder");
	dirNONprocess=getDirectory("Please, select the NON-processed images folder");
	dirrois=getDirectory("Please, select the ROIs folder");
	dirparam=getDirectory("PARAMETERS FOLDER");	
	print (dirimage);
	print (dirprocess);
	print(dirNONprocess);
	print(dirrois);
	print(dirparam);
	selectWindow("Log");
	saveAs("Text", dirparam+"folderparam.txt");
	selectWindow("Log");
	run("Close");
}

param=getBoolean("Do you want to use a file containing the info of the ROIs (ROIsparam.txt)?");
if (param==true){
	paramfile=File.openDialog("Select the txt file containing the information of the ROIs");
	Paramgeneral=File.openAsString(paramfile);
	Rparam=split(Paramgeneral, "\n");
	//Array.print(Rparam);
	n=parseInt(Rparam[1]);
	tiporoi=newArray(n);
	enlg=newArray(n);
	endist=newArray(n);
	saveboth=newArray(n);
	lineroiar=newArray(n);
	for(i=1; i<=n; i++){
		tiporoi[i-1]=Rparam[2+i];
		//print("tiproi: " +tiporoi[i-1]);
		lineroiar[i-1]=parseFloat(Rparam[3+n+i]);
		//print("lineroiar: " +lineroiar[i-1]);
		if (Rparam[6+((n-1)*2)+i]=="0") enlg[i-1]=false;
		else enlg[i-1]=true;
		//print("enlg: " +enlg[i-1]);
		endist[i-1]=Rparam[8+((n-1)*3)+i];
		//print("endist: " +endist[i-1]);
		if (Rparam[10+((n-1)*4)+i]=="0") saveboth[i-1]=false;
		else saveboth[i-1]=true;
		//print("saveboth: " +saveboth[i-1]);
	}

	if (Rparam[13+((n-1)*5)]=="0") lightback=false;
	else lightback=true;
	//print("lightback: " +lightback);
}

else{
	n=getNumber("How many ROI types do you want to define?", 1);
	print ("ROI types: \n"+n); 
	tiporoi=newArray(n);

		lineroiar=newArray(n);
		enlg=newArray(n);
		endist=newArray(n);
		saveboth=newArray(n);	 
		
	Dialog.create("ROIs names");
	Dialog.addMessage("ROI identification");
	for(i=1; i<=n; i++){
		Dialog.addString("Name for ROI type "+ i+ ":","ROI" +i );
			Dialog.addCheckbox("Draw line", 0);
			Dialog.addCheckbox("Enlarge", 0);
			Dialog.addNumber("Enlargement", 8);
			Dialog.addCheckbox("Save both line and enlarge", 1);
	}
	Dialog.addCheckbox("Light background", 0);
	Dialog.show();
	for(i=1; i<=n; i++){
		tiporoi[i-1]=Dialog.getString();
			lineroiar[i-1]=Dialog.getCheckbox();
			enlg[i-1]=Dialog.getCheckbox();
			endist[i-1]=Dialog.getNumber();
			saveboth[i-1]=Dialog.getCheckbox();
	}
	lightback=Dialog.getCheckbox();
	print("TIPO ROIs:");
	for (i=0; i<tiporoi.length; i++) print(tiporoi[i]);
	print("Draw line:");
	for (i=0; i<lineroiar.length; i++) print(lineroiar[i]);
	print("Enlarge:");
	for (i=0; i<enlg.length; i++) print(enlg[i]);
	print("Enlargement:");
	for (i=0; i<endist.length; i++) print(endist[i]);
	print("Save both line and enlarge:");
	for (i=0; i<saveboth.length; i++) print(saveboth[i]);
	print ("Light background", "\n"+lightback);
	
	
	selectWindow("Log");
	saveAs("Text", dirparam+"ROIsparam.txt");
	selectWindow("Log");
	run("Close");
}
														
if (lightback==true) run("Colors...", "foreground=black background=white selection=yellow");
	else run("Colors...", "foreground=white background=black selection=yellow");
	
for (i=0; i<tiporoi.length; i++){
	
	if (lineroiar[i]==true) {
		if(enlg[i]==true){
			if (File.exists(dirrois+tiporoi[i]+"Enlarged/")==false) File.makeDirectory(dirrois+tiporoi[i]+"Enlarged");
			if (saveboth[i]==true) if (File.exists(dirrois+tiporoi[i]+"Line/")==false) File.makeDirectory(dirrois+tiporoi[i]+"Line");
		}
		else if (File.exists(dirrois+tiporoi[i]+"Line/")==false) File.makeDirectory(dirrois+tiporoi[i]+"Line");
	}
	else if (File.exists(dirrois+tiporoi[i]+"/")==false) File.makeDirectory(dirrois+tiporoi[i]);
}



//Image view options

viewparam=getBoolean("Do you want to use a file containing the info of the view parameters (viewparam.txt)?");
if (viewparam==true){
	paramfile=File.openDialog("Select the txt file containing the information of the view");
	viewparam=File.openAsString(paramfile);
	Vparam=split(viewparam, "\n");
	projec=Vparam[1];
	protype=Vparam[3];
	chan=parseFloat(Vparam[5]);
	enh=Vparam[7];
}
else{
	
	nombreimagenes=getFileList(dirimage);
	run("Bio-Formats Importer", "open=["+ dirimage+ nombreimagenes[0]+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");	
	waitForUser("Check this first image and decide image view");
	getDimensions(width1, height1, channels1, slices1, frames1);
	
	arrProj=newArray("Max Intensity", "Sum Slices", "Average Intensity");
	arrChann=newArray(channels1);
	for (ch=0; ch<channels1; ch++) arrChann[ch]=ch+1;
	Dialog.create("Image view");
	Dialog.addCheckbox("Projection", false);
	Dialog.addChoice("Projection type", arrProj);
	Dialog.addChoice("Channel", arrChann);
	Dialog.addCheckbox("Enhance contrast", true);
	Dialog.show();
	
	selectImage(nombreimagenes[0]);
	close();
	
	projec=Dialog.getCheckbox();
	protype=Dialog.getChoice();
	chan=Dialog.getChoice();
	enh=Dialog.getCheckbox();

	print("Projection:");
	print(projec);
	print("Type of projection:");
	print(protype);
	print("Channel:");
	print(chan);
	print ("Enhance contrast:");
	print(enh);
	selectWindow("Log");
	saveAs("Text", dirparam+"viewparam.txt");
	selectWindow("Log");
	run("Close");
}







nombreimagenes=getFileList(dirimage);
for(i=0; i<nombreimagenes.length; i++){
	run("Bio-Formats Importer", "open=["+ dirimage+ nombreimagenes[i]+"] color_mode=Grayscale open_files view=Hyperstack stack_order=XYCZT");	
	
	name=File.nameWithoutExtension;
	procesada=false;
	selectWindow(nombreimagenes[i]);
	getDimensions(width2, height2, channels2, slices2, frames2);
	if (projec==true){
		run("Z Project...", "projection=["+protype+"]");
		rename("Projection");
	}
	else setSlice(round(channels2*slices2/2));
	getDimensions(width2, height2, channels2, slices2, frames2);
	if (channels2>1){
		Stack.setDisplayMode("grayscale");
	 	Stack.setChannel(chan);
	}
	
	if (enh==true) run("Enhance Contrast", "saturated=0.35");
	for(q=0; q<tiporoi.length; q++){
		if (lineroiar[q]==false) dibujaPol();
		else {
			dibujaLine(enlg[q], endist[q], saveboth[q]);
		}
	}
	selectWindow(nombreimagenes[i]);
	close();
	if (projec==true){
		selectWindow("Projection");
		close();
	}
	changedirectory();
}

function changedirectory(){
	if (procesada==false) File.rename(dirimage+nombreimagenes[i], dirNONprocess+nombreimagenes[i]);
	else File.rename(dirimage+nombreimagenes[i], dirprocess+nombreimagenes[i]);
}

function dibujaPol(){
	setTool("polygon");
		do{
			waitForUser("Please draw ROIs "+ tiporoi[q]);
			numberrois=roiManager("count");
			if (numberrois==0){
				waitForUser("YOU DID NOT DRAW ANY ROI");
				cont=getBoolean("Do you want to discard this image?");
			}
			else {
				roiManager("Show All");
				cont=getBoolean("Do you want to save this/these ROIs?");
			}
		}while (cont==false);
		numberrrois=roiManager("count");
		if (numberrois>0 && cont==true){
			if (numberrois>1){
				roiManager("Deselect");
				roiManager("Combine");
				roiManager("Add");
				numR=roiManager("Count");
				eraserR=newArray(numR-1);
				for (l=0; l<(numR-1); l++) eraserR[l]=l;
				roiManager("Select", eraserR);
				roiManager("Delete");
			}
			roiManager("Deselect");
			roiManager("Save", dirrois + tiporoi[q]+"/"+name+ ".zip");
			roiManager("Delete");
			procesada=true;
		}
}

function dibujaLine(enl, distenl, both){
	setTool("polyline");
		do{
			waitForUser("Please draw ROIs "+ tiporoi[q]);
			numberrois=roiManager("count");
			if (numberrois==0){
				waitForUser("YOU DID NOT DRAW ANY ROI");
				cont=getBoolean("Do you want to discard this image?");
			}
			else {
				roiManager("Show All");
				cont=getBoolean("Do you want to save this/these ROIs?");
			}
		}while (cont==false);
		numberrrois=roiManager("count");
		if (numberrois>0 && cont==true){
			if ((enl==true && both==true)|| enl==false){
				roiManager("Deselect");
				roiManager("Save", dirrois + tiporoi[q]+"Line/"+name+ ".zip");
				procesada=true;
			}
			run("Select None");
			
			if (enl==true){	
				if (numberrois>1){
					roiManager("Deselect");
					roiManager("Combine");
					roiManager("Add");
					numR=roiManager("Count");
					eraserR=newArray(numR-1);
					for (l=0; l<(numR-1); l++) eraserR[l]=l;
					roiManager("Select", eraserR);
					roiManager("Delete");
				}
				else {
					roiManager("Select",0);
					run("Line to Area");
					roiManager("Update");
				}
				roiManager("Select", 0);
				run("Enlarge...", "enlarge="+distenl);
				roiManager("Update");
				roiManager("Deselect");
				roiManager("Save", dirrois + tiporoi[q]+"Enlarged/"+name+ ".zip");
				procesada=true;
			}
			roiManager("Deselect");
			roiManager("Delete");
			run("Select None");
		}
} 