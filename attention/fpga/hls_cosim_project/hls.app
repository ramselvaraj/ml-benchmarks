<AutoPilot:project xmlns:AutoPilot="com.autoesl.autopilot.project" top="attention_int8_kernel" name="hls_cosim_project">
    <includePaths/>
    <libraryFlag/>
    <files>
        <file name="../../tb_attention_int8.cpp" sc="0" tb="1" cflags=" -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="attention_top.h" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="attention_int8.cpp" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
    </files>
    <solutions>
        <solution name="solution_cosim" status=""/>
    </solutions>
    <Simulation argv="/home/siyenga7/FPGA/testvectors/int8">
        <SimFlow name="csim" setup="false" optimizeCompile="false" clean="true" ldflags="-fno-lto -fno-use-linker-plugin" mflags=""/>
    </Simulation>
</AutoPilot:project>

