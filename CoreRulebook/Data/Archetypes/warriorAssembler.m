function warriorAssembler(fileNameRoot)
   
    %if no target given, assume that called directly, else assume called by
    %master
   
    if nargin < 1
        disp('Insufficient inputs provided');
        addpath('../Functions/');
        fileNameRoot = '../../Chapters/';
        originRoot = "";
    end
    
    f = readtable("Archetype Supplementals/Warrior_Stratagems.xlsx");
    h = height(f);
    shield = string.empty;
    wand = string.empty;
    blade = string.empty;
    c = {blade,wand,shield};
    text = "";
    for i = 1:h
        if ~isempty(f{i,1}{1})
            line = "\stratagem{";

            line = line + f{i,1}{1} +"}{";
            line = line + f{i,5}{1}+"}{";

            names = ["Blade","Wand","Shield"];
            incNames = string.empty;
            for j = 1:3
                if f{i,1+j}{1} == 'Y'
                    incNames(end+1) = names(j);
                    c{j}(end+1) = f{i,1}{1};
                end
            end

            for j = 1:length(incNames)
               line = line + incNames(j);
               if j < length(incNames)


                    if length(incNames) > 1 && j == length(incNames)-1
                        line = line + " or ";
                    else
                        line = line + ", ";
                    end
               end
            end
            line = line + " paradigm";
            if length(incNames) > 1
                line = line + "s";
            end
            line = line + "}";
            text = text + prepareText(line) + "\n";
        end
    end
    
    readFile = fileread("Warrior.tex");   
    insertPoint = strfind(readFile, '%%StratBegin');
    endPoint = strfind(readFile, '%%StratEnd');
    firstHalf = prepareText(readFile(1:insertPoint+11),0);
    secondHalf = prepareText(readFile(endPoint:end),0);
    fullText = firstHalf +"\n" + text  + "\n"+ secondHalf;
    
    fullText = insertSchools(c,fullText);
    
    FID = fopen("Warrior.tex",'w');
    fprintf(FID, fullText);
    fclose(FID);
end
    
function fullText = insertSchools(c,fullText)
    
    keys = ["Blade","Wands", "Sield"];
    
    for i = 1:length(keys)
        array = c{i};
        line = "";
        for j = 1:length(array)
            line = line + array(j);
            if j < length(array)
                if j == length(array)-1
                    line = line + " } and {\it ";
                else
                    line = line + ", ";
                end
            end
        end
        
        bKey = "%%" + keys(i) + "Begin";
        eKey = "%%" + keys(i) + "End";
        
        insertPoint = strfind(fullText, bKey);
        endPoint = strfind(fullText, eKey);
        charText = char(fullText);
        
        firstHalf = charText(1:insertPoint+12);
        secondHalf = charText(endPoint:end);
        
        fullText = firstHalf + "" + prepareText(line) + "\n" + secondHalf;
    end
   
end