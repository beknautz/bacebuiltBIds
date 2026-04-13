<tr class="phase-row">
  <td>
    <input type="hidden" name="phase_id[]" value="0">
    <input type="text" name="phase_name[]" class="form-control"
           placeholder="e.g. Site Preparation" value="">
  </td>
  <td>
    <input type="text" name="phase_desc[]" class="form-control"
           placeholder="What happens during this phase" value="">
  </td>
  <td>
    <input type="number" name="phase_days[]" class="form-control text-end"
           value="0" min="0">
  </td>
  <td>
    <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
      <i class="bi bi-x"></i>
    </button>
  </td>
</tr>
