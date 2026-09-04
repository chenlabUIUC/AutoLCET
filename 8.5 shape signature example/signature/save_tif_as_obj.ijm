function action(input, output, filename) {
        open(input + filename);
        print(input + filename);
        x = output+filename+".obj";
        run("Wavefront .OBJ ...", "stack=filename threshold=125 resampling=5 red green blue save=x");
        close();
}

input = "Z:/shape signature example/signature/tifData/";
output = "Z:/shape signature example/signature/surfaceData/";

list = getFileList(input);
for (i = 0; i < list.length; i++){
        action(input, output, list[i]);
}