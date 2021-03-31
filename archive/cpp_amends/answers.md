# cpp amends

Author: lukoshkin

## task-a

The first function repeats the second and is inferior. Remove it
In the body of the second function remove the comments describing the marker
`[VEC->FWLIST]` and the line of code wrapped with it (including the markers).
These lines are no longer valid in the newer versions of the hd-simulator
repository from where these code snippets were taken.

---

```cpp
/**
 * Fills cavities with different colors.
 * Logs ids of segmented pores to "cavities.bin".
 */
// TODO: Add conditional logging
void Raw2Mesh::colorFillDSU() {
  for (uint current_id: pore_ids) {
    std::vector<uint> active_cells;

    for (uint pos: cell_neighbors) {
      uint neighbor_id = CI2CI(current_id, pos);
      if (array[neighbor_id] >= 0)
          active_cells.push_back(neighbor_id);
    }
    dsets.makeSet(current_id);
    for (uint i=1; i<active_cells.size(); ++i)
      dsets.unionSets(active_cells.front(), active_cells[i]);
    if (!active_cells.empty())
      dsets.unionSets(active_cells.front(), current_id);
  }
  for (uint current_id: pore_ids)
    cavities[dsets.findSet(current_id)].push_back(Ip2I(current_id));
}
```

## task-b

Fix the indentation.  
This mess often happens in old Vim versions (not in Neovim at least)
when pasting sth from the clipboard. One may not always fix formatting
afterwards. Thus, it is better to paste from the clipboard as follows:

```vim
:set paste
<C-S-V>
:set nopaste
```

---

```cpp
/**
 * Docstring
 */
void Stokes::applySlipNoSlip(uint dir, PetscInt val=-1) {
  std::vector<PetscInt> I;
  std::vector<PetscInt> DIM;

  switch (dir) {
    case 0:
      I = {0, 1, 2};
      DIM = {Nx, Ny, Nz};
      break;
    case 1:
      I = {1, 0, 2};
      DIM = {Ny, Nx, Nz};
      break;
    case 2:
      I = {1, 2, 0};
      DIM = {Nz, Nx, Ny};
      break;
    default:
      PetscPrintf(PETSC_COMM_WORLD,
          "dir takes only 0, 1, 2 values\n");
  }

  for (PetscInt p = 0; p < pad; ++p) {
    for (PetscInt i = 0; i < DIM[1]; ++i) {
      for (PetscInt j = 0; j < DIM[2]; ++j) {
        std::vector<PetscInt> L;
        L = {p, i, j};
        data[flatIndex(L[I[0]], L[I[1]], L[I[2]])] = val;

        L = {DIM[0]-pad+p, i, j};
        data[flatIndex(L[I[0]], L[I[1]], L[I[2]])] = val;
      }
    }
  }
}
```

