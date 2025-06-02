import cocotb
import random
from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge, FallingEdge,
    Timer, ReadOnly
)
from cocotb.result import TestFailure

DATA_WIDTH = 32

async def reset_fifo(dut):
    dut.arst.value = 0
    dut.we_i.value = 0
    dut.re_i.value = 0
    dut.data_w.value = 0
    await Timer(20, units="ns")
    if dut.arst.value != 0:
        raise TestFailure(f"arst != 0")
    dut._log.info("→ Driving arst = 1 (reset)")
    dut.arst.value = 1
    await Timer(20, units="ns")
    if dut.arst.value != 1:
        raise TestFailure(f"arst != 1")
    dut._log.info("→ Driving arst = 0 (release reset)")
    dut.arst.value = 0
    await RisingEdge(dut.clk_w)
    await RisingEdge(dut.clk_r)
    await Timer(20, units="ns")

async def writer(dut, test_data):
    dut._log.info(f"Starting Writer {test_data}")
    for val in test_data:
        dut._log.info(f"Running Writer {val}")
        while dut.full.value:
            await RisingEdge(dut.clk_w)
        dut.data_w.value = val
        dut.we_i.value = 1
        # dut._log.info(f"Running Writer: we_i = {dut.we_i.value}")
        await RisingEdge(dut.clk_w)
        # dut._log.info(f"Running Writer: we_i = {dut.we_i.value}")
        dut.we_i.value = 0
        # await Timer(random.randint(10, 20), units="ns")
        await RisingEdge(dut.clk_w)
    dut._log.info("Ending Writer")

async def reader(dut, num_items, expected_data):
    dut._log.info(f"Starting Reader {expected_data}")
    read_data = []
    await Timer(100, units="ns")  # Delay to allow writes to get started
    for _ in range(num_items):
        while dut.empty.value:
            await RisingEdge(dut.clk_r)

        # Assert read enable
        dut.re_i.value = 1
        # dut._log.info(f"Running Reader: re_i = {dut.re_i.value}")
        await RisingEdge(dut.clk_r)
        dut.re_i.value = 0
        # dut._log.info(f"Running Reader: re_i = {dut.re_i.value}")

        # Wait one more cycle to allow data_r to update
        await RisingEdge(dut.clk_r)
        await ReadOnly()

        # Check if data_r is valid
        raw_val = dut.data_r.value
        if not raw_val.is_resolvable:
            raise TestFailure(f"data_r is unresolvable (x/z): {raw_val}")

        read_val = raw_val.integer
        dut._log.info(f"Running Reader: read_val = {read_val}")
        read_data.append(read_val)

        # Add randomized delay to simulate realistic async read behavior
        await Timer(random.randint(5, 20), units="ns")
    if (dut.empty.value == 1 and dut.full.value == 1):
        raise TestFailure(f"Empty == 1 and Full == 1")
    assert read_data == expected_data, f"Mismatch! Expected {expected_data}, got {read_data}"
    dut._log.info("Ending Reader")

############################# MAIN TESTS #############################
@cocotb.test()
async def template_test(dut):
    cocotb.start_soon(Clock(dut.clk_r, 13, units='ns').start())
    cocotb.start_soon(Clock(dut.clk_w, 7, units='ns').start())

    await reset_fifo(dut)
    test_data = [random.randint(0, 255) for _ in range(8)]

    await cocotb.start_soon(writer(dut, test_data))
    await cocotb.start_soon(reader(dut, len(test_data), test_data))

    Timer(2200, units="ns")
