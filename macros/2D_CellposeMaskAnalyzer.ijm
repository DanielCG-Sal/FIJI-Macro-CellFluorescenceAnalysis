/* 
    2D_CellposeMaskAnalyzer is an ImageJ macro developed to obtain data from images using masks created with Cellpose.
    Copyright (C) 2023  Jorge Valero Gómez-Lobo.

    2D_CellposeMaskAnalyzer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

   2D_CellposeMaskAnalyzer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
//License
Dialog.create("GNU GPL License");
Dialog.addMessage("2D_CellposeMaskAnalyzer  Copyright (C) 2023 Jorge Valero Gomez-Lobo.");
Dialog.setInsets(10, 20, 0);
Dialog.addMessage(" StaiNucJ comes with ABSOLUTELY NO WARRANTY; click on help button for details.");
Dialog.setInsets(0, 20, 0);
Dialog.addMessage("This is free software, and you are welcome to redistribute it under certain conditions; click on help button for details.");
Dialog.addHelp("http://www.gnu.org/licenses/gpl.html");
Dialog.show();

roiManager("reset");
if (isOpen("Results")){
	run("Clear Results");
}
run ("Close All");

setBatchMode(true);



generalDir=getDirectory("Select the general folder");
folders=getFileList(generalDir);

run("Set Measurements...", "area mean redirect=None decimal=3");

Dialog.create("Folders and parameters");
Dialog.addChoice("Select Images Folder", folders);
Dialog.addChoice("Select Mask Folder", folders);
Dialog.addChoice("Select ROIs Folder", folders);
Dialog.addNumber("Channel", 1);
Dialog.addNumber("pixels/micron", 1.86);
Dialog.show();

dirIm=generalDir+Dialog.getChoice();
dirMask=generalDir+Dialog.getChoice();
dirRois=generalDir+Dialog.getChoice();
chann=Dialog.getNumber();
pmic=Dialog.getNumber();

folders2=getFileList(dirRois);

Dialog.create("ROIs Folders");
Dialog.addChoice("Select Areas Folder", folders2);
Dialog.addChoice("Select Negative control folder", folders2);
Dialog.show();
dirArea=dirRois+Dialog.getChoice();
dirNeg=dirRois+Dialog.getChoice();

tablecreator2("PerCell", newArray("Carpeta", "Image", "ROI_ID", "Area", "Raw Mean", "Corrected Mean", "Mean control"));
tablecreator2("Cell_count", newArray("Carpeta", "Image", "ROIs tot", "Area_region", "Density"));


Images=getFileList(dirIm);

for(i=0; i<Images.length; i++){
	run("Bio-Formats Importer", "open=["+dirIm+Images[i]+"] color_mode=Grayscale open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");;
	name=File.nameWithoutExtension();
	rename(Images[i]);
	run("Duplicate...", "duplicate title=dupl channels="+chann);
	selectWindow(Images[i]);
	close();
	selectWindow("dupl");
	run("Set Scale...", "distance=1.86 known=1 unit=um");
	if (File.exists(dirMask+name+"_cp_masks.png") && File.exists(dirArea+name+".zip")){
		run("Bio-Formats Importer", "open=["+dirMask+name+"_cp_masks.png] color_mode=Grayscale open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");;
		rename(name+"_cp_masks.png");
		run("Label image to ROIs");
		selectWindow(name+"_cp_masks.png");
		close();
		selectWindow("dupl");
		roiManager("Measure");
		selectWindow("Results");
		Areas=Table.getColumn("Area");
		Mean=Table.getColumn("Mean");
		roiManager("List");
		selectWindow("Overlay Elements of dupl");
		Ids=Table.getColumn("Name");
		run("Close");
		roiManager("reset");
		if (isOpen("Results")){
			run("Clear Results");
		}
		roiManager("Open", dirArea+name+".zip");
		roiManager("Open", dirNeg+name+".zip");
		roiManager("Measure");
		selectWindow("Results");
		Areas2=Table.getColumn("Area");
		Mean2=Table.getColumn("Mean");
		roiManager("reset");
		if (isOpen("Results")){
			run("Clear Results");
		}
		tableprinter2("Cell_count", newArray(generalDir, name, Areas.length, Areas2[0], Areas.length/Areas2[0]));
		for (ii=0; ii<Areas.length; ii++) tableprinter2("PerCell", newArray(generalDir, name, Ids[ii], Areas[ii], Mean[ii], Mean[ii]-Mean2[1], Mean2[1]));
	}
	run("Close All");	
}

savetab("Cell_count", generalDir);
savetab("PerCell", generalDir);

function tablecreator2(tabname, tablearray){
	//tabname="bu";
	//tablearray=newArray("Date", "Hour","Xdisp","Ydisp", "Contrast Sat", "Roll rad", "Tolerance", "Cell size");
	run("New... ", "name=["+tabname+"] type=Table");
	headings=tablearray[0];
	for (i=1; i<tablearray.length; i++)headings=headings+"\t"+tablearray[i];
	print ("["+tabname+"]", "\\Headings:"+ headings);
	
}

function tableprinter2(tabname, tablearray){
	line=tablearray[0];
	for (i=1; i<tablearray.length; i++) line=line+"\t"+tablearray[i];
	print ("["+tabname+"]", line);
	
}



function  savetab(tablename, dirRes){
	//tablename=getList("window.titles");
		selectWindow(tablename);
		 saveAs("Text", dirRes+tablename+".xls");
	}
